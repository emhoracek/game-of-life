module Garden.ModelTests exposing (..)

import Array
import Dict
import Expect
import Garden.Grid.Model exposing (CellState (..))
import Garden.Display.Model exposing (Display)
import Test exposing (Test, describe, test)
import Garden.Model exposing (moveVisibleGrid)

centeredAt : ( Int, Int ) -> Display
centeredAt (r,c) = 
    { rows = r * 2 + 1 , 
      columns = c * 2 + 1, 
      plants = Array.empty }

suite : Test
suite =
    describe "model"
        [  describe "moving grid" 
            [ test "grid at 1,1 to 1,1" <| 
                \_ -> 
                    let grid = Dict.fromList [((0,0), Alive)] in
                    Expect.equal (moveVisibleGrid grid (centeredAt (1,1)) (centeredAt (1,1))) grid,
              test "grid at 1,1 to 0,0" <| 
                \_ -> 
                    let grid1 = Dict.fromList [((1,1), Alive)]
                        grid2 = Dict.fromList [((0,0), Alive)] in
                    Expect.equal (moveVisibleGrid grid1 (centeredAt (1,1)) (centeredAt (0,0))) grid2 ,
              test "grid at 0,0 to 4,4" <| 
                \_ -> 
                    let grid1 = Dict.fromList [((2,2), Alive)]
                        grid2 = Dict.fromList [((5,5), Alive)] in
                    Expect.equal (moveVisibleGrid grid1 (centeredAt (1,1)) (centeredAt (4,4))) grid2  
            ] 
        ]