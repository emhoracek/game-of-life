defmodule GardenOfLife.GridTest do
  use ExUnit.Case, async: true

  import GardenOfLife.Grid

  def empty_grid() do
    Map.new()
  end

  def mkgrid(list) do
    Map.new(list)
  end

  def alive_cell(r, c) do
    {{r, c}, %{"foo" => "bar"}}
  end

  def blue_cell(r, c) do
    {{r, c}, %{"color" => "blue"}}
  end

  def blue_data() do
    %{"color" => "blue"}
  end

  describe "is_alive" do
    test "in an empty grid, all are false" do
      grid = empty_grid()
      assert is_alive(grid, {0, 0}) == false
    end

    test "in a grid with a point, that point is true" do
      grid = mkgrid([alive_cell(0, 0)])
      assert is_alive(grid, {0, 0}) == true
    end

    test "in a grid with a point, other points are false" do
      grid = mkgrid([alive_cell(0, 0)])
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
      grid = empty_grid()

      assert get_live_neighbors(grid, {0, 0}) == empty_grid()
    end

    test "for grid with only that point returns none" do
      grid = mkgrid([alive_cell(0, 0)])

      assert get_live_neighbors(grid, {0, 0}) == empty_grid()
    end

    test "for grid with only non-neighboring point returns none" do
      grid = mkgrid([alive_cell(0, 0)])

      assert get_live_neighbors(grid, {0, 0}) == empty_grid()
    end

    test "for grid with a neighboring point returns it" do
      grid = mkgrid([alive_cell(0, 0)])

      assert get_live_neighbors(grid, {0, 1}) == grid
    end

    test "returns neighbors but not non-neighbors" do
      grid = mkgrid([alive_cell(0, 0), alive_cell(5, 5)])

      assert get_live_neighbors(grid, {0, 1}) == mkgrid([alive_cell(0, 0)])
    end
  end

  describe "will_be_alive" do
    test "for cell in empty grid, returns false" do
      grid = empty_grid()

      assert will_be_alive(grid, alive_cell(0, 0)) == false
    end

    test "for cell in grid with one elem, returns false" do
      grid = mkgrid([alive_cell(0, 0)])

      assert will_be_alive(grid, alive_cell(0, 0)) == false
    end

    test "for live cell in grid with two live neighbors, returns true" do
      grid = mkgrid([alive_cell(0, 0), alive_cell(0, 1), alive_cell(1, 1)])

      assert will_be_alive(grid, alive_cell(0, 1)) == true
    end

    test "for live cell in grid with three live neighbors, returns true" do
      grid = mkgrid([alive_cell(0, 0), alive_cell(0, 1), alive_cell(1, 1), alive_cell(-1, 1)])

      assert will_be_alive(grid, alive_cell(0, 1)) == true
    end

    test "for cell in grid with four live neighbors, returns false" do
      grid =
        MapSet.new([
          alive_cell(0, 0),
          alive_cell(0, 1),
          alive_cell(1, 1),
          alive_cell(-1, 1),
          alive_cell(1, 0)
        ])

      assert will_be_alive(grid, alive_cell(0, 1)) == false
    end

    test "for dead cell in grid with three live neighbors, returns true" do
      grid = mkgrid([alive_cell(0, 0), alive_cell(1, 1), alive_cell(-1, 1)])

      assert will_be_alive(grid, alive_cell(0, 1)) == true
    end

    test "for dead cell in grid with two live neighbors, returns false" do
      grid = mkgrid([alive_cell(0, 0), alive_cell(1, 1)])

      assert will_be_alive(grid, alive_cell(0, 1)) == false
    end

    test "for dead cell in grid with one live neighbor, returns false" do
      grid = mkgrid([alive_cell(0, 0)])

      assert will_be_alive(grid, alive_cell(0, 1)) == false
    end
  end

  describe "step" do
    test "for empty grid, empty grid" do
      grid = empty_grid()

      assert step(grid) == grid
    end

    test "for grid with one cell, empty grid" do
      grid = mkgrid([alive_cell(0, 0)])

      assert step(grid) == empty_grid()
    end

    test "grid with three cells" do
      # - o  -> o o
      # o o     o o
      grid = mkgrid([alive_cell(0, 1), alive_cell(1, 0), alive_cell(1, 1)])

      assert step(grid) ==
               mkgrid([alive_cell(0, 0), alive_cell(0, 1), alive_cell(1, 0), alive_cell(1, 1)])
    end

    test "grid with more rows" do
      # - o -  -> o o -
      # o o -     o o o
      # - - o     - o -
      grid = mkgrid([alive_cell(0, 1), alive_cell(1, 0), alive_cell(1, 1), alive_cell(2, 2)])

      result =
        mkgrid([
          alive_cell(0, 0),
          alive_cell(0, 1),
          alive_cell(1, 0),
          alive_cell(1, 1),
          alive_cell(1, 2),
          alive_cell(2, 1)
        ])

      assert step(grid) == result
    end

    test "even larger" do
      # - o - -  -> o o o -
      # o o - o     o o - -
      # - - o -     - - o -
      # o o - -     - o - -
      grid =
        mkgrid([
          alive_cell(0, 1),
          alive_cell(1, 0),
          alive_cell(1, 1),
          alive_cell(1, 3),
          alive_cell(2, 2),
          alive_cell(3, 0),
          alive_cell(3, 1)
        ])

      result =
        mkgrid([
          alive_cell(0, 0),
          alive_cell(0, 1),
          alive_cell(0, 2),
          alive_cell(1, 0),
          alive_cell(1, 1),
          alive_cell(2, 2),
          alive_cell(3, 1)
        ])

      assert step(grid) == result
    end

    test "even larger with blue data" do
      # - o - -  -> o o o -
      # o o - o     o o - -
      # - - o -     - - o -
      # o o - -     - o - -
      grid =
        mkgrid([
          blue_cell(0, 1),
          blue_cell(1, 0),
          blue_cell(1, 1),
          blue_cell(1, 3),
          blue_cell(2, 2),
          blue_cell(3, 0),
          blue_cell(3, 1)
        ])

      result =
        mkgrid([
          blue_cell(0, 0),
          blue_cell(0, 1),
          blue_cell(0, 2),
          blue_cell(1, 0),
          blue_cell(1, 1),
          blue_cell(2, 2),
          blue_cell(3, 1)
        ])

      assert step(grid) == result
    end
  end

  describe "toggle_cell" do
    test "empty grid, makes that cell alive" do
      grid = empty_grid()

      assert toggle_cell(grid, alive_cell(0, 0)) == mkgrid([alive_cell(0, 0)])
    end

    test "grid with that one element, kills it" do
      grid = mkgrid([alive_cell(0, 0)])

      assert toggle_cell(grid, alive_cell(0, 0)) == empty_grid()
    end

    test "kills given live element, but keeps others" do
      grid = mkgrid([alive_cell(0, 0), alive_cell(1, 1)])

      assert toggle_cell(grid, alive_cell(0, 0)) == mkgrid([alive_cell(1, 1)])
    end
  end

  describe "to_point" do
    test "valid point" do
      assert to_coords("1,1") == {1,1}
    end

    test "invalid point" do
      assert to_coords("apple") == nil
    end
  end

  describe "for_plot" do
    test "valid points" do
      assert for_plot(%{"1,1" => %{"foo" => "bar"}}) == mkgrid([alive_cell(1, 1)])
    end

    test "invalid points" do
      assert for_plot([{"apple", %{"foo" => "bar"}}]) == empty_grid()
    end
  end

  describe "stringify_keys" do
    test "empty grid" do
      assert stringify_keys(empty_grid()) == Map.new()
    end

    test "valid points" do
      assert stringify_keys(mkgrid([alive_cell(1, 1)])) == %{"1,1" => %{"foo" => "bar"}}
    end
  end

  describe "step_cell - plain cells " do
    test "empty grid" do
      assert step_cell(empty_grid(), {0, 0}) == nil
    end

    test "alive cell with no neighbors" do
      assert step_cell(mkgrid([alive_cell(1, 1)]), {1, 1}) == nil
    end

    test "alive cell with two neighbors" do
      assert step_cell(mkgrid([alive_cell(0, 0), alive_cell(0, 1), alive_cell(1, 1)]), {0, 1}) ==
               %{"foo" => "bar"}
    end

    test "dead cell with three neighbors" do
      assert step_cell(mkgrid([alive_cell(0, 0), alive_cell(0, 1), alive_cell(1, 1)]), {1, 0}) ==
                %{"foo" => "bar"}
    end
  end

  describe "step_cell - blue cells " do
    test "empty grid" do
      assert step_cell(empty_grid(), {0, 0}) == nil
    end

    test "alive cell with no neighbors" do
      assert step_cell(mkgrid([blue_cell(1, 1)]), {1, 1}) == nil
    end

    test "alive cell with two neighbors" do
      assert step_cell(mkgrid([blue_cell(0, 0), blue_cell(0, 1), blue_cell(1, 1)]), {0, 1}) ==
               blue_data()
    end

    test "dead cell with three neighbors" do
      assert step_cell(mkgrid([blue_cell(0, 0), blue_cell(0, 1), blue_cell(1, 1)]), {1, 0}) ==
               blue_data()
    end
  end

  describe "make_child" do
    test "all the same" do
      assert make_child({1, 1, 1}) == 1
    end

    test "two are the same" do
      assert make_child({2, 1, 2}) == 2
    end

    test "all different" do
      assert make_child({1, 2, 3}) == 3
    end

    test "all different, different numbers" do
      assert make_child({3, 1, 2}) == 2
    end
  end
end
