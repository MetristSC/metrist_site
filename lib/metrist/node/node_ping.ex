defmodule Metrist.Node.NodePing do
  @doc """
  When we see a Node ping, check what we know about
  the node. Register it if necessary and send a monitor
  ping in any case.
  """
  require Logger
  alias Metrist.Node.Command

  def ping_received(account_uuid, node_id) do
    c = case by_uuid(account_uuid, node_id) do
          nil ->
            %Command.Create{
              uuid: Id.generate(),
              account_uuid: account_uuid,
              node_id: node_id}
          node ->
            %Command.HandlePing{
              uuid: node.uuid}
        end
    Logger.info("Node ping received, doing #{inspect c}")
    Metrist.App.dispatch(c)
  end

  defp by_uuid(account_uuid, node_id) do
    Metrist.Node.Projection.by_account_and_node_id(account_uuid, node_id)
    |> Metrist.Repo.one()
  end

end
