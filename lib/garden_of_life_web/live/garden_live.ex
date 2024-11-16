defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view
  alias GardenOfLife.{Repo, Plot, Grid}
  alias GardenOfLife.PubSub, as: GardenPS
  import Ecto.Query, except: [update: 3]

  alias Phoenix.PubSub

  def mount(%{"plot" => name, "player" => player}, _session, socket) do
    PubSub.subscribe(GardenPS, "grid:#{name}")

    PubSub.broadcast(
      GardenPS,
      "grid:#{name}",
      {"chat", %{event: "Player joined: #{player}"}}
    )

    plot = Repo.one(from p in Plot, where: p.name == ^name)
    grid = Plot.grid(plot)

    colors = %{
      "options" => [Blue: "blue", Red: "red", Yellow: "yellow", Pink: "pink", Purple: "purple"]
    }

    {:ok,
     assign(socket, :grid, grid)
     |> assign(:interactive, true)
     |> assign(:colors, colors)
     |> assign(:color, "red")
     |> assign(:name, name)
     |> assign(:player, player)
     |> assign(:chat, [])
     |> assign(:playing, false)}
  end

  def handle_info({"play", _params}, socket) do
    {:noreply, assign(socket, :playing, true)}
  end

  def handle_info({"stop", _params}, socket) do
    {:noreply, assign(socket, :playing, false)}
  end

  def handle_info({"apply_grid", %{grid: grid}}, socket) do
    {:noreply, assign(socket, :grid, grid)}
  end

  def handle_info({"step", _params}, socket) do
    {:noreply, update(socket, :grid, &Grid.step/1)}
  end

  def handle_info(:work, socket) do
    if socket.assigns.playing == true do
      name = socket.assigns.name

      schedule_work()

      {:noreply,
       update(socket, :grid, fn g ->
         new = Grid.step(g)
         broadcast_grid(name, new)
       end)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({"chat", message}, socket) do
    {:noreply, update(socket, :chat, &[message | &1])}
  end

  def handle_event("step_grid", _params, socket) do
    name = socket.assigns.name

    {:noreply,
     update(socket, :grid, fn g ->
       new = Grid.step(g)
       broadcast_grid(name, new)
     end)}
  end

  def handle_event("play", _params, socket) do
    name = socket.assigns.name
    PubSub.broadcast(GardenPS, "grid:#{name}", {"play", {}})
    schedule_work()

    {:noreply, assign(socket, :playing, true)}
  end

  def handle_event("stop", _params, socket) do
    name = socket.assigns.name
    PubSub.broadcast(GardenPS, "grid:#{name}", {"stop", {}})
    {:noreply, assign(socket, :playing, false)}
  end

  def handle_event("save", _params, socket) do
    name = socket.assigns.name
    player = socket.assigns.player
    grid = socket.assigns.grid
    plot = Repo.one(from p in Plot, where: p.name == ^name)
    changeset = Plot.changeset(plot, %{grid: Grid.stringify_keys(grid)})

    if changeset.valid? do
      {res, _} = Repo.update(changeset)

      case res do
        :ok ->
          PubSub.broadcast(
            GardenPS,
            "grid:#{name}",
            {"chat", %{event: "#{player} has saved the current state of your garden plot."}}
          )

        _ ->
          PubSub.broadcast(
            GardenPS,
            "grid:#{name}",
            {"chat",
             %{
               event:
                 "#{player} attempted to save the current state of your garden plot, but it failed to save."
             }}
          )
      end
    else
      IO.puts("#{inspect(changeset)}")
    end

    {:noreply, socket}
  end

  def handle_event("toggle_cell", %{"row" => row, "column" => column}, socket) do
    name = socket.assigns.name
    color = socket.assigns.color

    fun = fn g ->
      coords = {String.to_integer(row), String.to_integer(column)}

      new =
        Grid.toggle_cell(g, {coords, %{"color" => color}})

      broadcast_grid(name, new)
    end

    {:noreply, update(socket, :grid, fun)}
  end

  def handle_event("change_color", %{"color" => color}, socket) do
    {:noreply, assign(socket, color: color)}
  end

  def broadcast_grid(name, new_grid) do
    PubSub.broadcast(GardenPS, "grid:#{name}", {"apply_grid", %{grid: new_grid}})
    new_grid
  end

  def schedule_work() do
    Process.send_after(self(), :work, 1_000)
  end
end
