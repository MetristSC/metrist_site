defmodule Metrist.User.RegistrationProcessManager do
  @moduledoc """
  When a user registers, they get a default account. This
  process takes care of that.
  """
  use Commanded.ProcessManagers.ProcessManager,
    application: Metrist.App,
    name: "UserRegistrationProcessManager"

  @derive Jason.Encoder
  defstruct [:uuid]

  def interested?(%Metrist.User.Event.Registered{uuid: uuid}) do
    {:start, uuid}
  end

  def interested?(%Metrist.Account.Event.Created{owner: uuid}) do
    {:stop, uuid}
  end

  def handle(_pm, %Metrist.User.Event.Registered{uuid: uuid}) do
    %Metrist.Account.Command.Create{
      uuid: Id.generate(),
      name: "Default Account",
      owner: uuid,
      api_key: UUID.uuid4()}
  end
end
