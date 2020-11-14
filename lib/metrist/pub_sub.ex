defmodule Metrist.PubSub do
  @moduledoc """
  Very thin layer over Phoenix PubSub so that we have consistency in subscriptions
  and publishes and can do some light information hiding.
  """
  require Logger

  def broadcast(topic, id, payload) do
    Logger.info("broadcast #{topic}:#{id} -> #{inspect payload}")
    Phoenix.PubSub.broadcast(__MODULE__, "#{topic}:#{id}", payload)
  end

  def subscribe(topic, id) do
    Logger.info("subscribe #{topic}:#{id}")
    Phoenix.PubSub.subscribe(__MODULE__, "#{topic}:#{id}")
  end

  def child_spec(_opts) do
    Phoenix.PubSub.child_spec(name: __MODULE__)
  end
end
