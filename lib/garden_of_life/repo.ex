defmodule GardenOfLife.Repo do
  use Ecto.Repo,
    otp_app: :garden_of_life,
    adapter: Ecto.Adapters.Postgres
end
