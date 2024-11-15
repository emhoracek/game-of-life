defmodule GardenOfLife.Plot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plots" do
    field :name, :string
    field :grid, {:map, {:map, :string}}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot, attrs) do
    plot
    |> cast(attrs, [:name, :grid])
    |> unique_constraint(:name, name: :plot_names_unique_index)
    |> validate_required([:name])
  end

  def grid(plot) do
    if (plot.grid) do
      GardenOfLife.Grid.for_plot(plot.grid)
    else
      Map.new()
    end
  end
end
