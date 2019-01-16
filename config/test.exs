use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fungus_toast, FungusToastWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :fungus_toast, FungusToast.Repo,
  username: "postgres",
  password: "postgres",
  database: "fungus_toast_test",
  hostname: System.get_env("PGHOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
