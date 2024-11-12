defmodule GardenOfLifeWeb.GardenLive do
  use GardenOfLifeWeb, :live_view

  def render(assigns) do
    ~H"""
    <table>
      <%= for row <- 0..9 do %>
        <tr>
          <%= for column <- 0..9 do %>
            <%= if GardenOfLife.Garden.is_alive(@grid, {row, column}) do%>
              <td class="cell w-6 h-6 bg-slate-100 text-center p-0 m-0"
                  phx-click="toggle_cell"
                  phx-value-row={row}
                  phx-value-column={column}> 🌸 </td>
            <% else %>
              <td class="cell w-6 h-6 bg-slate-300 text-center p-0 m-0"
                phx-click="toggle_cell"
                phx-value-row={row}
                phx-value-column={column}> &nbsp; </td>
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

  def handle_event("toggle_cell", %{"row" => row, "column" => column}, socket) do
    fun = fn g -> GardenOfLife.Garden.toggle_cell(g, { String.to_integer(row), String.to_integer(column)} ) end
    {:noreply, update(socket, :grid, fun)}
  end
end
