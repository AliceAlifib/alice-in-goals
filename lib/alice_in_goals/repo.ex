defmodule AliceInGoals.Repo do
  use Ecto.Repo,
    otp_app: :alice_in_goals,
    adapter: Ecto.Adapters.SQLite3
end
