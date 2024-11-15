defmodule GardenOfLife.Repo.Migrations.AlterGridTypeInPlots do
  use Ecto.Migration

  def change do
    alter table("plots") do
      remove :grid
      add :grid, {:map, {:map, :string}}, from: {:array, :string}
    end
  end
end
