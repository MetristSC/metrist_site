defmodule MetristWeb.Series do
  @moduledoc """
  Some utilities around series names. A fully qualified name is

  account_uuid/agent_name/series_name

  but this is not always what you want to display.
  """
  def full_name(account_uuid, agent_name, series_name) do
    "#{account_uuid}/#{agent_name}/#{series_name}"
  end
  def full_name(%{"account_uuid" => account_uuid,
                  "agent_name" => agent_name,
                  "series_name" => series_name}) do
    full_name(account_uuid, agent_name, series_name)
  end

  def short_name(full_name) do
    full_name
    |> split()
    |> elem(2)
  end

  def split(full_name) do
    [au, an, sn] = String.split(full_name, "/")
    {au, an, sn}
  end
end
