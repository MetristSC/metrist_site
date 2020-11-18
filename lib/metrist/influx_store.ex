defmodule Metrist.InfluxStore do
  use Instream.Connection,
    otp_app: :metrist
  require Logger

  # Space saver - we only write a data point this often.
  # TODO write an average for all the datapoints we do not write
  @min_secs_between_writes 300

  def initialize() do
    :ets.new(__MODULE__, [:public, :set, :named_table])
  end

  def write_from_agent(account_uuid, agent_id, payload) do
    needs_throttle = check_throttle(account_uuid, agent_id)
    do_write_from_agent(account_uuid, agent_id, payload, needs_throttle)
  end

  defp do_write_from_agent(_account_uuid, _agent_id, _payload, _throttle = true) do
    :ok
  end
  defp do_write_from_agent(account_uuid, agent_id, payload, _throttle = false) do
    points = Enum.map(payload, fn {measurement, [timestamp, fields, tags]} ->
      tags = Map.put(tags, "account_uuid", account_uuid)
      tags = Map.put(tags, "agent_id", agent_id)
      timestamp = Metrist.Timestamps.to(timestamp, :nanosecond)
      %{
        measurement: "#{account_uuid}/#{agent_id}/#{measurement}",
        fields: fields,
        tags: tags,
        timestamp: timestamp
      }
    end)
    case write(%{points: points}) do
      %{error: error} ->
        Logger.error("Influx write error for agent #{account_uuid}/#{agent_id}: #{inspect error}")
      _ -> nil
    end
    update_throttle(account_uuid, agent_id)
  end

  defp check_throttle(account_uuid, agent_id) do
    case :ets.lookup(__MODULE__, {account_uuid, agent_id}) do
      [{_key, last_time}] ->
        last_time + @min_secs_between_writes > :erlang.system_time(:second)
      [] ->
        false
    end
  end
  defp update_throttle(account_uuid, agent_id) do
    :ets.insert(__MODULE__, {{account_uuid, agent_id}, :erlang.system_time(:second)})
  end

  def series_of(account_uuid, agent_id) do
    query = "SHOW MEASUREMENTS WHERE account_uuid = '#{account_uuid}' AND agent_id = '#{agent_id}'"
    values = case query(query) do
      %{results: [%{series: [%{values: values}]}]}  -> values
      _ -> []
    end
    List.flatten(values)
  end

  def fields_of(series) do
    query = ~s/SHOW FIELD KEYS FROM "#{series}"/
    %{results: [%{series: [%{values: values}]}]} = query(query)
    values
  end

  @doc """
  Return values for a field in a series. `requested_unit` can be passed as
  an opimization: normally, the code will give back a `Metrist.Timestamp` style
  qualified timestamp, but if a specific unit is requested then that timestamp
  will be converted immediately to a bare value representing the requested units. This
  saves from looping over all the data twice.
  """
  def values_for(series, field, time_interval, requested_unit \\ nil) do
    query = ~s/SELECT #{field} FROM "#{series}"/
    query = case time_interval do
              {start, stop} ->
                start = start
                |> DateTime.from_unix!()
                |> DateTime.to_iso8601()
                stop = stop
                |> DateTime.from_unix!()
                |> DateTime.to_iso8601()
                "#{query} WHERE time >= '#{start}' AND time <= '#{stop}'"
                _ -> query
            end

    Logger.info("Query: #{query}")
    %{results: [%{series: [%{values: values}]}]} = query(query)
    Enum.map(values, fn [ts, v] ->
      {:ok, dt, 0} = DateTime.from_iso8601(ts)
      ut = DateTime.to_unix(dt, :nanosecond)
      ts = Metrist.Timestamps.from(:nanosecond, ut)
      ts = if requested_unit do
        Metrist.Timestamps.to(ts, requested_unit)
      else
        ts
      end
      [ts, v]
    end)
  end
end
