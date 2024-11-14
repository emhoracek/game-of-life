defmodule GardenOfLife.GridTest do
  use ExUnit.Case, async: true

  import GardenOfLife.Grid

  describe "is_alive" do
    test "in an empty grid, all are false" do
      grid = MapSet.new()
      assert is_alive(grid, {0, 0}) == false
    end

    test "in a grid with a point, that point is true" do
      grid = MapSet.new([{0, 0}])
      assert is_alive(grid, {0, 0}) == true
    end

    test "in a grid with a point, other points are false" do
      grid = MapSet.new([{0, 0}])
      assert is_alive(grid, {1, 1}) == false
    end
  end

  describe "get_neighbor_coords" do
    test "for zero, just returns the 8 offsets" do
      assert get_neighbor_coords({0, 0}) ==
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
    end

    test "for other points, return them offsetted" do
      assert get_neighbor_coords({1, 1}) ==
               MapSet.new([
                 {0, 2},
                 {0, 1},
                 {0, 0},
                 {1, 2},
                 {1, 0},
                 {2, 2},
                 {2, 0},
                 {2, 1}
               ])
    end
  end

  describe "get_live_neighbors" do
    test "for empty grid, returns none" do
      grid = MapSet.new()

      assert get_live_neighbors(grid, {0, 0}) == MapSet.new()
    end

    test "for grid with only that point returns none" do
      grid = MapSet.new([{0, 0}])

      assert get_live_neighbors(grid, {0, 0}) == MapSet.new()
    end

    test "for grid with only non-neighboring point returns none" do
      grid = MapSet.new([{0, 0}])

      assert get_live_neighbors(grid, {5, 5}) == MapSet.new()
    end

    test "for grid with a neighboring point returns it" do
      grid = MapSet.new([{0, 0}])

      assert get_live_neighbors(grid, {0, 1}) == grid
    end

    test "returns neighbors but not non-neighbors" do
      grid = MapSet.new([{0, 0}, {5, 5}])

      assert get_live_neighbors(grid, {0, 1}) == MapSet.new([{0, 0}])
    end
  end

  describe "will_be_alive" do
    test "for cell in empty grid, returns false" do
      grid = MapSet.new()

      assert will_be_alive(grid, {0, 0}) == false
    end

    test "for cell in grid with one elem, returns false" do
      grid = MapSet.new([{0, 0}])

      assert will_be_alive(grid, {0, 0}) == false
    end

    test "for live cell in grid with two live neighbors, returns true" do
      grid = MapSet.new([{0, 0}, {0, 1}, {1, 1}])

      assert will_be_alive(grid, {0, 1}) == true
    end

    test "for live cell in grid with three live neighbors, returns true" do
      grid = MapSet.new([{0, 0}, {0, 1}, {1, 1}, {-1, 1}])

      assert will_be_alive(grid, {0, 1}) == true
    end

    test "for cell in grid with four live neighbors, returns false" do
      grid = MapSet.new([{0, 0}, {0, 1}, {1, 1}, {-1, 1}, {1, 0}])

      assert will_be_alive(grid, {0, 1}) == false
    end

    test "for dead cell in grid with three live neighbors, returns true" do
      grid = MapSet.new([{0, 0}, {1, 1}, {-1, 1}])

      assert will_be_alive(grid, {0, 1}) == true
    end

    test "for dead cell in grid with two live neighbors, returns false" do
      grid = MapSet.new([{0, 0}, {1, 1}])

      assert will_be_alive(grid, {0, 1}) == false
    end

    test "for dead cell in grid with one live neighbor, returns false" do
      grid = MapSet.new([{0, 0}])

      assert will_be_alive(grid, {0, 1}) == false
    end
  end

  describe "step" do
    test "for empty grid, empty grid" do
      grid = MapSet.new()

      assert step(grid) == grid
    end

    test "for grid with one cell, empty grid" do
      grid = MapSet.new([{0, 0}])

      assert step(grid) == MapSet.new()
    end

    test "grid with three cells" do
      # - o  -> o o
      # o o     o o
      grid = MapSet.new([{0, 1}, {1, 0}, {1, 1}])

      assert step(grid) == MapSet.new([{0, 0}, {0, 1}, {1, 0}, {1, 1}])
    end

    test "grid with more rows" do
      # - o -  -> o o -
      # o o -     o o o
      # - - o     - o -
      grid = MapSet.new([{0, 1}, {1, 0}, {1, 1}, {2, 2}])
      result = MapSet.new([{0, 0}, {0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}])

      assert step(grid) == result
    end

    test "even larger" do
      # - o - -  -> o o o -
      # o o - o     o o - -
      # - - o -     - - o -
      # o o - -     - o - -
      grid = MapSet.new([{0, 1}, {1, 0}, {1, 1}, {1, 3}, {2, 2}, {3, 0}, {3, 1}])
      result = MapSet.new([{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {2, 2}, {3, 1}])

      assert step(grid) == result
    end
  end

  describe "toggle_cell" do
    test "empty grid, makes that cell alive" do
      grid = MapSet.new()

      assert toggle_cell(grid, {0, 0}) == MapSet.new([{0, 0}])
    end

    test "grid with that one element, kills it" do
      grid = MapSet.new([{0, 0}])

      assert toggle_cell(grid, {0, 0}) == MapSet.new()
    end

    test "kills given live element, but keeps others" do
      grid = MapSet.new([{0, 0}, {1, 1}])

      assert toggle_cell(grid, {0, 0}) == MapSet.new([{1, 1}])
    end
  end

  describe "to_point" do
    test "valid point" do
      assert to_point("1,1") == {1, 1}
    end

    test "invalid point" do
      assert to_point("apple") == nil
    end
  end

  describe "from_plot" do
    test "valid points" do
      assert for_plot(["1,1"]) == MapSet.new([{1, 1}])
    end

    test "invalid points" do
      assert for_plot(["apple"]) == MapSet.new()
    end
  end

  describe "diff_grid" do
    test "two empty grids" do
      assert diff_grid(MapSet.new(), MapSet.new()) == %{add: MapSet.new(), remove: MapSet.new()}
    end

    test "grids are the same" do
      assert diff_grid(MapSet.new([{1, 1}]), MapSet.new([{1, 1}])) == %{
               add: MapSet.new(),
               remove: MapSet.new()
             }
    end

    test "grids are completely different, use the new one" do
      assert diff_grid(MapSet.new([{1, 1}]), MapSet.new([{2, 2}])) == %{
               add: MapSet.new([{2, 2}]),
               remove: MapSet.new([{1, 1}])
             }
    end

    test "grids are not completely different" do
      assert diff_grid(MapSet.new([{0, 0}, {1, 1}]), MapSet.new([{0, 0}, {2, 2}])) == %{
               add: MapSet.new([{2, 2}]),
               remove: MapSet.new([{1, 1}])
             }
    end
  end

  describe "apply_diff" do
    test "empty grid, empty diff" do
      assert apply_diff(MapSet.new(), %{add: MapSet.new(), remove: MapSet.new()}) == MapSet.new()
    end

    test "non-empty grid, empty diff" do
      assert apply_diff(MapSet.new([{0, 0}]), %{add: MapSet.new(), remove: MapSet.new()}) ==
               MapSet.new([{0, 0}])
    end

    test "empty grid, diff with additions" do
      assert apply_diff(MapSet.new(), %{add: MapSet.new([{0, 0}]), remove: MapSet.new()}) ==
               MapSet.new([{0, 0}])
    end

    test "empty grid, diff with removals" do
      assert apply_diff(MapSet.new(), %{add: MapSet.new(), remove: MapSet.new([{0, 0}])}) ==
               MapSet.new()
    end

    test "non-empty grid, diff with removals" do
      assert apply_diff(MapSet.new([{0, 0}]), %{add: MapSet.new(), remove: MapSet.new([{0, 0}])}) ==
               MapSet.new()
    end

    test "non-empty grid, diff with additions" do
      assert apply_diff(MapSet.new([{0, 0}]), %{add: MapSet.new([{1, 1}]), remove: MapSet.new()}) ==
               MapSet.new([{0, 0}, {1, 1}])
    end

    test "non-empty grid, diff with both" do
      assert apply_diff(MapSet.new([{0, 0}]), %{
               add: MapSet.new([{1, 1}]),
               remove: MapSet.new([{0, 0}])
             }) == MapSet.new([{1, 1}])
    end
  end

  describe "to_plot" do
    test "empty grid" do
      assert to_plot(MapSet.new()) == []
    end

    test "valid points" do
      assert to_plot(MapSet.new([{1, 1}])) == ["1,1"]
    end
  end
end
