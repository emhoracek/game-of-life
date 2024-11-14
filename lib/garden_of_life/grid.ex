defmodule GardenOfLife.Grid do
  def for_plot(grid) do
    list =
      Enum.map(grid, fn s -> to_coords(s) end)
      |> Enum.filter(fn p -> p end)

    Map.new(list)
  end

  def to_plot(grid) do
    Enum.map(grid, fn {{r, c}, data} -> "#{r},#{c}: #{data}" end)
  end

  def to_coords(str) do
    regex = ~r/^(\d+),(\d+)/
    res = Regex.run(regex, str)

    if res && Kernel.length(res) == 3 do
      [_, r, c] = Regex.run(regex, str)
      {{String.to_integer(r), String.to_integer(c)}, true}
    end
  end

  def is_alive(grid, {r,c}) do
    Map.has_key?(grid, {r,c})
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

  def get_live_neighbors(grid, coords) do
    neighboring_coords = get_neighbor_coords(coords) #MapSet
    alive_coords = MapSet.new(Map.keys(grid))

    live_neighbor_coords = MapSet.to_list(MapSet.intersection(alive_coords, neighboring_coords))

    Map.take(grid, live_neighbor_coords)
  end

  def will_be_alive(grid, coords) do
    alive = is_alive(grid, Kernel.elem(coords, 0))
    neighbors = get_live_neighbors(grid, Kernel.elem(coords, 0))

    (alive && (Kernel.map_size(neighbors) == 2 || Kernel.map_size(neighbors) == 3)) ||
      (not alive && Kernel.map_size(neighbors) == 3)
  end

  def step(grid) do
    coords_to_check = MapSet.new(Enum.flat_map(grid, fn {coords, _data} -> get_neighbor_coords(coords) end))
    Map.new( for coords <- coords_to_check, will_be_alive(grid, {coords, true}), do: {coords, true})
  end

  def toggle_cell(grid, {coords, data}) do
    if is_alive(grid, coords) do
      Map.delete(grid, coords)
    else
      Map.put(grid, coords, data)
    end
  end

  def step_cell(grid, coords) do
    if will_be_alive(grid, {coords, true}) do
      { coords, true }
    end
  end
end
