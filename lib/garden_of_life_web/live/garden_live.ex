defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view

  def mount(_params, _session, socket) do
    grid = GardenOfLife.Garden.demo_grid
    {:ok, assign(socket, :grid, grid)}
  end

  def handle_event("step_grid", _params, socket) do
    fun = fn g -> GardenOfLife.Garden.step(g) end
    {:noreply, update(socket, :grid, fun)}
  end

  def handle_event("toggle_cell", %{"row" => row, "column" => column}, socket) do
    fun = fn g -> GardenOfLife.Garden.toggle_cell(g, { String.to_integer(row), String.to_integer(column)} ) end
    {:noreply, update(socket, :grid, fun)}
  end
end
