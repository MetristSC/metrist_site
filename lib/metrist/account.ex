defmodule Metrist.Account do
  @moduledoc """
  Account aggregate root.

  Accounts are used to manage permissions and API keys,
  mostly. Oh, and to collect moneys at some point.
  """
  use TypedStruct
  require Logger
  alias Metrist.Account.Command
  alias Metrist.Account.Event

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :owner, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :api_keys, list(String.t()), enforce: true
  end

  # Command handlers

  def execute(%__MODULE__{uuid: nil}, c = %Command.Create{}) do
    %Event.Created{uuid: c.uuid,
                   owner: c.owner,
                   name: c.name,
                   api_key: c.api_key}
  end
  def execute(_account, %Command.Create{}) do
    # Ignore duplicate registrations
    nil
  end

  # Event handlers

  def apply(account, e = %Event.Created{}) do
    %__MODULE__{account |
                uuid: e.uuid,
                owner: e.owner,
                name: e.name,
                api_keys: [e.api_key]}
  end
end
