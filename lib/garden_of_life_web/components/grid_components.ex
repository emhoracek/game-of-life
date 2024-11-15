defmodule GardenOfLifeWeb.GridComponents do
  use Phoenix.Component

  import GardenOfLife.Grid

  attr :grid, :map, required: true
  attr :interactive, :boolean, required: true

  def grid(assigns) do
    ~H"""
    <table class="mt-2 mb-2">
      <%= for row <- 0..19 do %>
        <tr>
          <%= for column <- 0..19 do %>
            <.cell
              cell={cell_at(@grid, {row, column})}
              row={row}
              column={column}
              interactive={@interactive}
            />
          <% end %>
        </tr>
      <% end %>
    </table>
    """
  end

  attr :cell, :map, required: true
  attr :interactive, :boolean, required: true
  attr :row, :integer, required: true
  attr :column, :integer, required: true

  def cell(%{interactive: interactive, row: row, column: column} = assigns) do
    assigns = assign(assigns, :click_handler, click_handler(interactive, row, column))

    ~H"""
    <td class={classes(@cell)} {@click_handler}>
      <%= flower_for(@cell) %>
    </td>
    """
  end

  def classes(cell) do
    cell_classes = "cell w-6 h-6 text-center p-0 m-1 border cursor-default"

    case cell do
      false -> "#{cell_classes} bg-slate-300"
      _ -> "#{cell_classes} bg-slate-100"
    end
  end

  def click_handler(interactive, row, column) do
    if interactive do
      %{"phx-click" => "toggle_cell", "phx-value-row" => row, "phx-value-column" => column}
    else
      %{}
    end
  end

  def flower_for(cell) do
    case cell do
      false -> " "
      _ -> "🌸"
    end
  end
end
