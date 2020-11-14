defmodule Metrist.App do
  use Commanded.Application,
     otp_app: :metrist,
     event_store: [
       adapter: Commanded.EventStore.Adapters.EventStore,
       event_store: Metrist.EventStore
     ]

  router Metrist.User.Router
  router Metrist.Account.Router
  router Metrist.Agent.Router
end
