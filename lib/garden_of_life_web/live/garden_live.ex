defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view
  alias GardenOfLife.{Repo, Plot}
  import Ecto.Query, except: [update: 3]

  def mount(%{"plot" => name}, _session, socket) do
    plot = Repo.one(from p in Plot, where: p.name == ^name)
    grid = Plot.garden(plot)
    {:ok, assign(socket, :grid, grid)}
  end

  def mount(_params, _session, socket) do
    grid = GardenOfLife.Garden.demo_grid()
    {:ok, assign(socket, :grid, grid)}
  end

  def handle_event("step_grid", _params, socket) do
    fun = fn g -> GardenOfLife.Garden.step(g) end
    {:noreply, update(socket, :grid, fun)}
  end

  def handle_event("toggle_cell", %{"row" => row, "column" => column}, socket) do
    fun = fn g ->
      GardenOfLife.Garden.toggle_cell(g, {String.to_integer(row), String.to_integer(column)})
    end

    {:noreply, update(socket, :grid, fun)}
  end
end
