defmodule GardenOfLife.Plot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plots" do
    field :name, :string
    field :grid, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot, attrs) do
    plot
    |> cast(attrs, [:name, :grid])
    |> validate_required([:name])
  end

  def garden(plot) do
    GardenOfLife.Garden.for_plot(plot.grid)
  end
end
