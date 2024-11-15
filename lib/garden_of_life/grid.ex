defmodule GardenOfLife.Grid do
  def for_plot(grid) do
    for {str, data} <- grid,
      reduce: %{} do
        acc ->
          case to_coords(str) do
            nil -> acc
            coords -> Map.put(acc, coords, data)
          end
      end
  end

  def stringify_keys(grid) do
    Map.new(Enum.map(grid, fn blah ->
      case blah do
        {{r, c}, data} -> {"#{r},#{c}", data}
        _ -> nil
      end
    end))
  end

  def to_coords(str) do
    regex = ~r/^(\d+),(\d+)/
    res = Regex.run(regex, str)

    if res && Kernel.length(res) == 3 do
      [_, r, c] = Regex.run(regex, str)
      {String.to_integer(r), String.to_integer(c)}
    end
  end

  def cell_at(grid, {r, c}) do
    Map.get(grid, {r, c}) || false
  end

  def is_alive(grid, {r, c}) do
    Map.has_key?(grid, {r, c})
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
    neighboring_coords = get_neighbor_coords(coords)
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
    coords_to_check =
      for {coords, _data} <- grid, reduce: MapSet.new() do
        acc -> MapSet.union(acc, get_neighbor_coords(coords))
      end

    cells =
      for coords <- coords_to_check,
          cell <- [step_cell(grid, coords)],
          !is_nil(cell),
          do: {coords, cell}

    Map.new(cells)
  end

  def toggle_cell(grid, {coords, data}) do
    if is_alive(grid, coords) do
      Map.delete(grid, coords)
    else
      Map.put(grid, coords, data)
    end
  end

  def make_child({a, b, c}) when a == b or a == c do
    a
  end

  def make_child({_a, b, c}) when b == c do
    b
  end

  def make_child({_a, _b, c}) do
    c
  end

  def step_cell(grid, coords) do
    cell = cell_at(grid, coords)
    neighbors = get_live_neighbors(grid, coords)

    if cell && (Kernel.map_size(neighbors) == 2 || Kernel.map_size(neighbors) == 3) do
      cell
    else
      if Kernel.map_size(neighbors) == 3 do
        make_child(List.to_tuple(Map.values(neighbors)))
      end
    end
  end
end
