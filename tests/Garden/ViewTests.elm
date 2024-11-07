module Garden.ViewTests exposing (..)

import Dict
import Expect
import Garden.Grid.Model exposing (CellState(..), Grid)
import Garden.Model exposing (Plant(..))
import Garden.View exposing (..)
import List exposing ((::))
import Test exposing (Test, describe, test)


smallGrid : Grid
smallGrid =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 1 )
          , Dead
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Alive
          )
        ]



-- A - A
-- A - -


sparseGrid : Grid
sparseGrid =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 2 )
          , Alive
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 3000, 301 )
          , Alive
          )
        ]


suite : Test
suite =
    describe "Game of Life"
        [ describe "toRows"
            [ test "converts grid to rows for display" <|
                \_ ->
                    Expect.equal
                        (toRows smallGrid (List.repeat 2 (List.repeat 3 Blue)))
                        [ [ ( Alive, Blue ), ( Dead, Blue ), ( Dead, Blue ) ]
                        , [ ( Alive, Blue ), ( Alive, Blue ), ( Dead, Blue ) ]
                        ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (toRows sparseGrid (List.repeat 3 (List.repeat 3 Blue)))
                        [ [ ( Alive, Blue ), ( Dead, Blue ), ( Alive, Blue ) ]
                        , [ ( Alive, Blue ), ( Dead, Blue ), ( Dead, Blue ) ]
                        , [ ( Dead, Blue ), ( Dead, Blue ), ( Dead, Blue ) ]
                        ]
            ]
        , describe "toPlants"
            [ test "converts grid to rows for display" <|
                \_ ->
                    Expect.equal
                        (toDisplayGrid { rows = 2, columns = 3 } smallGrid)
                        [ [ Just Blue, Nothing, Nothing ]
                        , [ Just Blue, Just Blue, Nothing ]
                        ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (toDisplayGrid { rows = 3, columns = 3 } sparseGrid)
                        [ [ Just Blue, Nothing, Just Blue ]
                        , [ Just Blue, Nothing, Nothing ]
                        , [ Nothing, Nothing, Nothing ]
                        ]
            ]
        , describe "toColumns"
            [ test "converts row of grid to list of cells for display" <|
                \_ ->
                    Expect.equal
                        (toColumns smallGrid 0 (List.repeat 3 Blue))
                        [ ( Alive, Blue ), ( Dead, Blue ), ( Dead, Blue ) ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (toColumns sparseGrid 0 (List.repeat 3 Blue))
                        [ ( Alive, Blue ), ( Dead, Blue ), ( Alive, Blue ) ]
            ]
        ]
