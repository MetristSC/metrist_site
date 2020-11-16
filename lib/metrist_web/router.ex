defmodule MetristWeb.Router do
  use MetristWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MetristWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/api", MetristWeb do
    post "/ping", PingController, :index
  end

  scope "/", MetristWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/home", DashboardLive
    live "/series/:account_uuid/:agent_name/:series_name", AgentSeriesLive
  end

  scope "/auth", MetristWeb do
    pipe_through :browser

    post "/logout", AuthController, :delete
    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MetristWeb.Telemetry
    end
  end
end
