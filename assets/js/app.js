// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"
import "phoenix_html"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

import PhxChartComponent from "./metrics_live"

let Hooks = {
  PhxChartComponent: PhxChartComponent
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken}
})

liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
