defmodule GardenOfLife.Repo.Migrations.AddUniqueConstraintToPlots do
  use Ecto.Migration

  def change do
    create unique_index(:plots, [:name], name: :plot_names_unique_index)
  end
end
