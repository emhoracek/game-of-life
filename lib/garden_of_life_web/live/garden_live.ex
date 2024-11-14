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


  def handle_info({"play", _params}, socket) do
    {:noreply, assign(socket, :playing, true)}
  end


  def handle_info({"stop", _params}, socket) do
    {:noreply, assign(socket, :playing, false)}
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

  def handle_info({"step", _params}, socket) do
    fun = fn g ->
      GardenOfLife.Garden.step(g)
    end

    {:noreply, update(socket, :grid, fun)}
  end

  def handle_info(:work, socket) do
    playing = socket.assigns.playing
    if playing == true do
      fun = fn g ->
         new = GardenOfLife.Garden.step(g)
         set_grid(new)
      end

      schedule_work()

      {:noreply, update(socket, :grid, fun)}
    else
      {:noreply, socket}
    end
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

  def handle_event("play", _params, socket) do
    PubSub.broadcast(GardenOfLife.PubSub, "grid:first", {"play", {}})
    schedule_work()

    {:noreply, assign(socket, :playing, true)}
  end

  def handle_event("stop", _params, socket) do
    PubSub.broadcast(GardenOfLife.PubSub, "grid:first", {"stop", {}})
    {:noreply, assign(socket, :playing, false)}
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

  def schedule_work() do
    Process.send_after(self(), :work, 1_000) # In 1 sec1
  end
end
