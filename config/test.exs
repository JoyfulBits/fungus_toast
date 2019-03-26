use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fungus_toast, FungusToastWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn, backends: [:console], compile_time_purge_level: :debug

# Configure your database
config :fungus_toast, FungusToast.Repo,
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  database: "fungus_toast_test",
  hostname: System.get_env("PGHOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
