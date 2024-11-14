defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view
  alias GardenOfLife.{Repo, Plot}
  import Ecto.Query, except: [update: 3]

  alias Phoenix.PubSub

  def mount(%{"plot" => name}, _session, socket) do
    PubSub.subscribe(GardenOfLife.PubSub, "grid:#{name}")
    plot = Repo.one(from p in Plot, where: p.name == ^name)
    grid = Plot.garden(plot)

    {:ok,
     assign(socket, :grid, grid)
     |> assign(:name, name)
     |> assign(:chat, [])
     |> assign(:playing, false)}
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
      name = socket.assigns.name

      fun = fn g ->
        new = GardenOfLife.Garden.step(g)
        set_grid(name, new)
      end

      schedule_work()

      {:noreply, update(socket, :grid, fun)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({"chat", message}, socket) do
    fun = fn ms ->
      [message | ms]
    end

    {:noreply, update(socket, :chat, fun)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def handle_event("step_grid", _params, socket) do
    name = socket.assigns.name

    fun = fn g ->
      new = GardenOfLife.Garden.step(g)
      set_grid(name, new)
    end

    {:noreply, update(socket, :grid, fun)}
  end

  def handle_event("play", _params, socket) do
    name = socket.assigns.name
    PubSub.broadcast(GardenOfLife.PubSub, "grid:#{name}", {"play", {}})
    schedule_work()

    {:noreply, assign(socket, :playing, true)}
  end

  def handle_event("stop", _params, socket) do
    name = socket.assigns.name
    PubSub.broadcast(GardenOfLife.PubSub, "grid:#{name}", {"stop", {}})
    {:noreply, assign(socket, :playing, false)}
  end

  def handle_event("save", _params, socket) do
    name = socket.assigns.name
    grid = socket.assigns.grid
    plot = Repo.one(from p in Plot, where: p.name == ^name)
    changeset = Plot.changeset(plot, %{grid: GardenOfLife.Garden.to_plot(grid)})

    if changeset.valid? do
      {res, _} = Repo.update(changeset)

      case res do
        :ok ->
          PubSub.broadcast(
            GardenOfLife.PubSub,
            "grid:#{name}",
            {"chat", %{event: "Garden state saved."}}
          )

        _ ->
          PubSub.broadcast(
            GardenOfLife.PubSub,
            "grid:#{name}",
            {"chat", %{event: "Failed to save garden state."}}
          )
      end
    else
      IO.puts("#{inspect(changeset)}")
    end

    {:noreply, socket}
  end

  def handle_event("toggle_cell", %{"row" => row, "column" => column}, socket) do
    name = socket.assigns.name

    fun = fn g ->
      coords = {String.to_integer(row), String.to_integer(column)}

      new =
        GardenOfLife.Garden.toggle_cell(g, coords)

      update_grid(name, g, new)
    end

    {:noreply, update(socket, :grid, fun)}
  end

  def set_grid(name, newGrid) do
    PubSub.broadcast(GardenOfLife.PubSub, "grid:#{name}", {"apply_grid", %{grid: newGrid}})
    newGrid
  end

  def update_grid(name, old, new) do
    unless old == new do
      diff = GardenOfLife.Garden.diff_grid(old, new)
      PubSub.broadcast(GardenOfLife.PubSub, "grid:#{name}", {"apply_diff", %{diff: diff}})
    end

    new
  end

  def schedule_work() do
    # In 1 sec
    Process.send_after(self(), :work, 1_000)
  end
end
