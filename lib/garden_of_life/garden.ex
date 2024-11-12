defmodule GardenOfLife.Garden do
  def demo_grid do
    MapSet.new([{5, 5}, {5, 6}, {5, 7}])
  end

  def is_alive(grid, point) do
    MapSet.member?(grid, point)
  end

  def get_neighbor_coords({r, c}) do
    offsets =
      MapSet.new([
        {-1, -1},
        {-1, 0},
        {-1, 1},
        {0, -1},
        {0, 1},
        {1, -1},
        {1, 0},
        {1, 1}
      ])

    MapSet.new(Enum.map(offsets, fn {offsetR, offsetC} -> {r + offsetR, c + offsetC} end))
  end

  def get_live_neighbors(grid, point) do
    neighboring_coords = get_neighbor_coords(point)
    MapSet.filter(grid, fn p -> MapSet.member?(neighboring_coords, p) end)
  end

  def will_be_alive(grid, point) do
    alive = is_alive(grid, point)
    neighbors = get_live_neighbors(grid, point)

    (alive && (MapSet.size(neighbors) == 2 || MapSet.size(neighbors) == 3)) ||
      (not alive && MapSet.size(neighbors) == 3)
  end

  def step(grid) do
    neighbors = MapSet.new(Enum.flat_map(grid, fn coords -> get_neighbor_coords(coords) end))
    MapSet.new(Enum.filter(neighbors, fn coords -> will_be_alive(grid, coords) end))
  end

  def toggle_cell(grid, cell) do
    if is_alive(grid, cell) do
      MapSet.delete(grid, cell)
    else
      MapSet.put(grid, cell)
    end
  end
end
