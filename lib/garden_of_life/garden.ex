defmodule GardenOfLife.Garden do
  def for_plot(grid) do
    list =
      Enum.map(grid, fn s -> to_point(s) end)
      |> Enum.filter(fn p -> p end)

    MapSet.new(list)
  end

  def to_plot(grid) do
    Enum.map(grid, fn {r, c} -> "#{r},#{c}" end)
  end

  def demo_grid do
    MapSet.new([{5, 5}, {5, 6}, {5, 7}])
  end

  def to_point(str) do
    res = Regex.run(~r/^(\d+),(\d+)$/, str)

    if res && Kernel.length(res) == 3 do
      [_, r, c] = Regex.run(~r/^(\d+),(\d+)$/, str)
      {String.to_integer(r), String.to_integer(c)}
    end
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

  def diff_grid(old, new) do
    add = MapSet.difference(new, old)
    remove = MapSet.difference(old, new)
    %{add: add, remove: remove}
  end

  def apply_diff(grid, %{add: add, remove: remove}) do
    with_additions = MapSet.union(grid, add)
    MapSet.difference(with_additions, remove)
  end
end
