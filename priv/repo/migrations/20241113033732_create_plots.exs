defmodule GardenOfLife.Repo.Migrations.CreatePlots do
  use Ecto.Migration

  def change do
    create table(:plots) do
      add :name, :string, null: false
      add :grid, {:array, :string}, default: []

      timestamps(type: :utc_datetime)
    end
  end
end
