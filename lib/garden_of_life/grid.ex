defmodule GardenOfLife.Grid do
  def for_plot(grid) do
    list =
      Enum.map(grid, fn s -> to_point(s) end)
      |> Enum.filter(fn p -> p end)

    Map.new(list)
  end

  def to_plot(grid) do
    Enum.map(grid, fn {{r, c}, data} -> "#{r},#{c}: #{data}" end)
  end

  def to_point(str) do
    regex = ~r/^(\d+),(\d+)/
    res = Regex.run(regex, str)

    if res && Kernel.length(res) == 3 do
      [_, r, c] = Regex.run(regex, str)
      {{String.to_integer(r), String.to_integer(c)}, true}
    end
  end

  def is_alive(grid, {{r,c}, _data}) do
    Map.has_key?(grid, {r,c})
  end

  def is_alive(grid, cell) do
    MapSet.member?(grid, cell)
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
    neighboring_coords = get_neighbor_coords(point) #MapSet
    alive_coords = MapSet.new(Map.keys(grid))

    live_neighbor_coords = MapSet.to_list(MapSet.intersection(alive_coords, neighboring_coords))

    Map.take(grid, live_neighbor_coords)
  end

  def will_be_alive(grid, point) do
    alive = is_alive(grid, point)
    neighbors = get_live_neighbors(grid, Kernel.elem(point, 0))

    (alive && (Kernel.map_size(neighbors) == 2 || Kernel.map_size(neighbors) == 3)) ||
      (not alive && Kernel.map_size(neighbors) == 3)
  end

  def step(grid) do
    coords_to_check = MapSet.new(Enum.flat_map(grid, fn {coords, _data} -> get_neighbor_coords(coords) end))
    Map.new( for coord <- coords_to_check, will_be_alive(grid, {coord, true}), do: {coord, true})
  end

  def toggle_cell(grid, {{r,c}, data}) do
    if is_alive(grid, {{r,c}, data}) do
      Map.delete(grid, {r,c})
    else
      Map.put(grid, {r,c}, data)
    end
  end

  def step_cell(grid, point) do
    if will_be_alive(grid, {point, true}) do
      { point, true }
    end
  end
end
