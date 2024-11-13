defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view
  alias GardenOfLife.{Repo, Plot}
  import Ecto.Query, except: [update: 3]

  alias Phoenix.PubSub

  def mount(%{"plot" => name}, _session, socket) do
    PubSub.subscribe(GardenOfLife.PubSub, "grid:#{name}")
    plot = Repo.one(from p in Plot, where: p.name == ^name)
    grid = Plot.garden(plot)

    {:ok, assign(socket, :grid, grid)}
  end

  def mount(_params, _session, socket) do
    grid = GardenOfLife.Garden.demo_grid()
    {:ok, assign(socket, :grid, grid)}
  end

  def handle_info({"apply_diff", %{diff: diff}}, socket) do
    gridFun = fn grid ->
      GardenOfLife.Garden.apply_diff(grid, diff)
    end

    {:noreply, update(socket, :grid, gridFun)}
  end

  def handle_info({"apply_grid", %{grid: grid}}, socket) do
    {:noreply, assign(socket, :grid, grid)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_event("step_grid", _params, socket) do
    fun = fn g ->
      new = GardenOfLife.Garden.step(g)
      set_grid(new)
    end

    {:noreply, update(socket, :grid, fun)}
  end

  def handle_event("toggle_cell", %{"row" => row, "column" => column}, socket) do
    fun = fn g ->
      coords = {String.to_integer(row), String.to_integer(column)}

      new =
        GardenOfLife.Garden.toggle_cell(g, coords)

      update_grid(g, new)
    end

    {:noreply, update(socket, :grid, fun)}
  end

  def set_grid(newGrid) do
    PubSub.broadcast(GardenOfLife.PubSub, "grid:first", {"apply_grid", %{grid: newGrid}})
    newGrid
  end

  def update_grid(old, new) do
    unless old == new do
      diff = GardenOfLife.Garden.diff_grid(old, new)
      PubSub.broadcast(GardenOfLife.PubSub, "grid:first", {"apply_diff", %{diff: diff}})
    end

    new
  end
end
