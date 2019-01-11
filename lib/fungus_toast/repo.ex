defmodule FungusToast.Repo do
  use Ecto.Repo,
    otp_app: :fungus_toast,
    adapter: Ecto.Adapters.Postgres
end
