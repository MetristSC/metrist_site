defmodule Metrist.InfluxStore do
  use Instream.Connection,
    otp_app: :metrist

  def write_from_agent(account_uuid, agent_id, payload) do
    IO.puts("Write #{inspect payload}")
    points = Enum.map(payload, fn {measurement, [timestamp, fields, tags]} ->
      tags = Map.put(tags, "account_uuid", account_uuid)
      tags = Map.put(tags, "agent_id", agent_id)
      %{
        measurement: "#{account_uuid}/#{agent_id}/#{measurement}",
        fields: fields,
        tags: tags,
        timestamp: timestamp
      }
    end)
    write(%{points: points})
  end

  def series_of(account_uuid, agent_id) do
    query = "SHOW MEASUREMENTS WHERE account_uuid = '#{account_uuid}' AND agent_id = '#{agent_id}'"
    IO.puts("Querying: #{query}")
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

  def values_for(series, field) do
    query = ~s/SELECT #{field} from "#{series}"/
    %{results: [%{series: [%{values: values}]}]} = query(query)
    Enum.map(values, fn [ts, v] ->
      {:ok, dt, 0} = DateTime.from_iso8601(ts)
      ut = DateTime.to_unix(dt, :microsecond)
      [ut, v]
    end)
  end
end
