defmodule Metrist.InfluxStore do
  use Instream.Connection,
    otp_app: :metrist

  def write_from_agent(account_uuid, node_id, payload) do
    points = Enum.map(payload, fn {measurement, points} ->
      [timestamp, values_and_tags] = points
      Enum.map(values_and_tags, fn [value, field_name, tags, unit, kind] ->
        tags = Map.put(tags, "account_uuid", account_uuid)
        tags = Map.put(tags, "node_id", node_id)
        tags = if unit == "", do: tags, else: Map.put(tags, "unit", unit)
        tags = Map.put(tags, "kind", kind)
        %{
          measurement: "#{account_uuid}/#{node_id}/#{measurement}",
          fields: %{field_name => value},
          tags: tags,
          timestamp: timestamp
        }
      end)
    end)
    points = List.flatten(points)
    write(%{points: points})
  end

  def series_of(account_uuid, node_id) do
    query = "SHOW MEASUREMENTS WHERE account_uuid = '#{account_uuid}' AND node_id = '#{node_id}'"
    IO.puts("Querying: #{query}")
    %{results: [%{series: [%{values: values}]}]} = query(query)
    List.flatten(values)
  end

  def fields_of(series) do
    query = ~s/SHOW FIELD KEYS FROM "#{series}"/
    %{results: [%{series: [%{values: values}]}]} = query(query)
    values
  end

end
