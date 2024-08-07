defmodule Questions.Repo do
  use Ecto.Repo,
    otp_app: :questions,
    adapter: Ecto.Adapters.Postgres
end
