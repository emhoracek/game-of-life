defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view

  def render(assigns) do
    ~H"""
    <table>
      <%= for row <- 1..10 do %>
        <tr>
          <%= for column <- 1..10 do %>
            <%= if GardenOfLife.Garden.is_alive(@grid, {row, column}) do%>
              <td class="cell w-6 h-6 bg-slate-100 text-center p-0 m-0"> 🌸 </td>
            <% else %>
              <td class="cell w-6 h-6 bg-slate-300 text-center p-0 m-0"> &nbsp; </td>
            <% end %>
          <% end %>
        </tr>
      <% end %>
    </table>

    <button phx-click="step_grid">Step</button>
    """
  end

  def mount(_params, _session, socket) do
    grid = GardenOfLife.Garden.demo_grid
    {:ok, assign(socket, :grid, grid)}
  end

  def handle_event("step_grid", _params, socket) do
    fun = fn g -> GardenOfLife.Garden.step(g) end
    {:noreply, update(socket, :grid, fun)}
  end
end
