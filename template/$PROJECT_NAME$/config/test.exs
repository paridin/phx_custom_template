import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :<%= @project_name %>, <%= @project_name_camel_case %>Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :<%= @project_name %>, <%= @project_name_camel_case %>Web.Endpoint,
  server: true

config :<%= @project_name %>, :sql_sandbox, true
