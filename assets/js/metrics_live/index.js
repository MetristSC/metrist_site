import { ColorWheel, LineColor } from './color_wheel'
import _css from 'uplot/dist/uPlot.min.css'
import uPlot from 'uplot'

const SeriesValue = (options) => {
  if (!options.unit) return {}

  return {
    value: (u, v) => v == null ? '--' : v.toFixed(3) + ` ${options.unit}`
  }
}

const XSeriesValue = (options) => {
  return {
    value: '{YYYY}/{MM}/{DD} {HH}:{mm}:{ss}'
  }
}

const YAxisValue = (options) => {
  if (!options.unit) return {}

  return {
    values: (u, vals, space) => vals.map(v => +v.toFixed(2) + ` ${options.unit}`)
  }
}

const XAxis = (_options) => {
  return {
    space: 55,
    values: [
      // tick incr          default         year                         month    day                    hour     min                sec       mode
      [3600 * 24 * 365,   "{YYYY}",         null,                        null,    null,                  null,    null,              null,        1],
      [3600 * 24 * 28,    "{MMM}",          "\n{YYYY}",                  null,    null,                  null,    null,              null,        1],
      [3600 * 24,         "{M}/{D}",        "\n{YYYY}",                  null,    null,                  null,    null,              null,        1],
      [3600,              "{HH}",           "\n{YYYY}/{MM}/{DD}",            null,    "\n{M}/{D}",           null,    null,              null,        1],
      [60,                "{HH}:{mm}",     "\n{YYYY}/{MM}/{DD}",            null,    "\n{M}/{D}",           null,    null,              null,        1],
      [1,                 ":{ss}",         "\n{YYYY}/{MM}/{DD} {HH}:{mm}",   null,    "\n{M}/{D} {HH}:{mm}",  null,    "\n{HH}:{mm}",  null,        1],
      [0.001,             ":{ss}.{fff}",   "\n{YYYY}/{MM}/{DD} {HH}:{mm}",   null,    "\n{M}/{D} {HH}:{mm}",  null,    "\n{HH}:{mm}",  null,        1],
    ]
  }
}

const YAxis = (options) => {
  return {
    show: true,
    size: 70,
    space: 15,
    ...YAxisValue(options)
  }
}

const minChartSize = {
  width: 100,
  height: 300
}

// Limits how often a funtion is invoked
function throttle(cb, limit) {
  let wait = false;

  return () => {
    if (!wait) {
      requestAnimationFrame(cb);
      wait = true;
      setTimeout(() => {
        wait = false;
      }, limit);
    }
  }
}

export const newSeriesConfig = (options, index = 0) => {
  return {
    ...LineColor.at(index),
    ...SeriesValue(options),
    label: options.label,
    spanGaps: true,
    points: { show: false }
  }
}

/** Telemetry Metrics **/

// Maps an ordered list of dataset objects into an ordered list of data points.
const dataForDatasets = (datasets) => datasets.slice(0).map(({ data }) => data)

// Handler for an untagged CommonMetric
function nextValueForCallback({ y, z }, callback) {
  this.datasets[0].data.push(z)
  let currentValue = this.datasets[1].data[this.datasets[1].data.length - 1] || 0
  let nextValue = callback.call(this, y, currentValue)
  this.datasets[1].data.push(nextValue)
}

const findLastNonNullValue = (data) => data.reduceRight((a, c) => (c != null && a == null ? c : a), null)

// Handler for a tagged CommonMetric
function nextTaggedValueForCallback({ x, y, z }, callback) {
  // Find or create the series from the tag
  let seriesIndex = this.datasets.findIndex(({ key }) => x === key)
  if (seriesIndex === -1) {
    seriesIndex = this.datasets.push({ key: x, data: Array(this.datasets[0].data.length).fill(null) }) - 1
    this.chart.addSeries(newSeriesConfig({ label: x, unit: this.options.unit }, seriesIndex - 1), seriesIndex)
  }

  // Add the new timestamp + value, keeping datasets aligned
  this.datasets = this.datasets.map((dataset, index) => {
    if (index === 0) {
      dataset.data.push(z)
    } else if (index === seriesIndex) {
      dataset.data.push(callback.call(this, y, findLastNonNullValue(dataset.data) || 0))
    } else {
      dataset.data.push(null)
    }
    return dataset
  })
}

const getPruneThreshold = ({ pruneThreshold = 1000 }) => pruneThreshold

// Handles the basic metrics like Counter, LastValue, and Sum.
class CommonMetric {
  static __projections() {
    return {
      counter: (y, value) => value + 1,
      last_value: (y) => y,
      sum: (y, value) => value + y
    }
  }

  static getConfig(options) {
    return {
      class: options.kind,
      title: options.title,
      width: options.width,
      height: options.height,
      series: [
        { ...XSeriesValue() },
        newSeriesConfig(options, 0)
      ],
      scales: {
        y: {
          min: 0,
          max: 1
        },
      },
      axes: [
        XAxis(),
        YAxis(options)
      ]
    }
  }

  static initialData() {
    return [[], []]
  }

  constructor(chart, options) {
    this.__callback = this.constructor.__projections()[options.metric]
    this.chart = chart
    this.datasets = [{ key: "|x|", data: [] }]
    this.options = options
    this.pruneThreshold = getPruneThreshold(options)

    if (options.tagged) {
      this.chart.delSeries(1)
      this.__handler = nextTaggedValueForCallback
    } else {
      this.datasets.push({ key: options.label, data: [] })
      this.__handler = nextValueForCallback
    }
  }

  handleMeasurements(measurements) {
    // slide the dataset - we prune the oldest stuff so we can add the
    // new measurements without adding to the total number of data points.
    // however, we let things fill up until the prune value is reached.
    let currentSize = this.datasets[0].data.length
    let toPrune = (currentSize - this.pruneThreshold) + measurements.length
    if (toPrune > 0) {
      this.datasets = this.datasets.map(({ data, ...rest }) => {
        return { data: data.slice(toPrune), ...rest }
      })
    }

    measurements.forEach((measurement) => this.__handler.call(this, measurement, this.__callback))
    this.chart.setData(dataForDatasets(this.datasets))
  }

  clear() {
    this.datasets = this.datasets.map(({ data, ...rest }) => {
      return { data: [], ...rest }
    })
    this.chart.setData([])
  }
}

export class TelemetryChart {
  constructor(chartEl, options) {
    if (!options.metric) {
      throw new TypeError(`No metric type was provided`)
    }

    const metric = CommonMetric
    this.uplotChart = new uPlot(metric.getConfig(options), metric.initialData(options), chartEl)
    this.metric = new metric(this.uplotChart, options)

    // setup the data buffer
    let isBufferingData = typeof options.refreshInterval !== "undefined"
    this._buffer = []
    this._timer = setInterval(
      this._flushToChart.bind(this),
      +options.refreshInterval
    )
  }

  clearTimers() { clearInterval(this._timer) }

  resize(boundingBox) {
    this.uplotChart.setSize({
      width: Math.max(boundingBox.width, minChartSize.width),
      height: minChartSize.height
    })
  }

  pushData(measurements) {
    if (!measurements.length) return
    this._buffer = this._buffer.concat(measurements)
  }

  clearData() {
    this._buffer = []
    this.metric.clear()
  }

  _pushToChart(measurements) {
    this.metric.handleMeasurements(measurements)
  }

  // clears the buffer and pushes the measurements
  _flushToChart() {
    let measurements = this._flushBuffer()
    if (!measurements.length) { return }
    this._pushToChart(measurements)
  }

  // clears and returns the buffered data as a flat array
  _flushBuffer() {
    if (this._buffer && !this._buffer.length) { return [] }
    let measurements = this._buffer
    this._buffer = []
    return measurements.reduce((acc, val) => acc.concat(val), [])
  }
}

/** LiveView Hook **/

const PhxChartComponent = {
  mounted() {
    let chartEl = this.el.parentElement.querySelector('.chart')
    let size = chartEl.getBoundingClientRect()
    let options = Object.assign({}, chartEl.dataset, {
      tagged: (chartEl.dataset.tags && chartEl.dataset.tags !== "") || false,
      width: Math.max(size.width, minChartSize.width),
      height: minChartSize.height
    })

    this.chart = new TelemetryChart(chartEl, options)

    window.addEventListener("resize", throttle(() => {
      let newSize = chartEl.getBoundingClientRect()
      this.chart.resize(newSize)
    }))
  },
  updated() {
    let chartEl = this.el.parentElement.querySelector('.chart')
    if (chartEl.dataset.clear == "true") {
      // We're doing a full refresh
      this.chart.clearData();
    }

    const data = Array
      .from(this.el.children || [])
      .map(({ dataset: { x, y, z } }) => {
        // converts y-axis value (z) to number,
        // converts timestamp (z) from µs to fractional seconds
        return { x, y: +y, z: +z / 1e6 }
      })

    if (data.length > 0) {
      this.chart.pushData(data)
    }
  },
  destroyed() {
    this.chart.clearTimers()
  }
}

export default PhxChartComponent
