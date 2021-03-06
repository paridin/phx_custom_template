defmodule <%= @project_name_camel_case %>Web.Router do
  use <%= @project_name_camel_case %>Web, :router
  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :admins_only do
    plug(:basic_auth, username: "<%= @basic_auth_user %>", password: "<%= @basic_auth_password %>")
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {<%= @project_name_camel_case %>Web.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", <%= @project_name_camel_case %>Web do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/", <%= @project_name_camel_case %>Web.Live do
    pipe_through(:browser)

    live("/example", WeatherExample, :index, as: :live_example)
  end

  scope "/admin", <%= @project_name_camel_case %>Web do
    pipe_through([:browser, :admins_only])
    # admin routes, basic_auth is not for production.
  end

  scope "/" do
    pipe_through([:browser, :admins_only])
    live_dashboard("/dashboard", metrics: <%= @project_name_camel_case %>Web.Telemetry)
    # Note: if you have ecto installed with ecto_psql_extras remove previous and uncomment the follow line.
    # live_dashboard("/dashboard", metrics: <%= @project_name_camel_case %>Web.Telemetry, ecto_repos: [<%= @project_name_camel_case %>.Repo])
  end
end
