module CellTeams.Grid.ModelTests exposing (..)

import CellTeams.Grid.Model exposing (..)
import Dict
import Expect
import List exposing ((::))
import Test exposing (Test, describe, test)


smallerGrid : Grid
smallerGrid =
    Dict.fromList
        [ ( ( 0, 0 )
          , Dead
          )
        , ( ( 0, 1 )
          , Alive
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Alive
          )
        ]


smallerGridNext : Grid
smallerGridNext =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 1 )
          , Alive
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Alive
          )
        ]


exampleGrid : Grid
exampleGrid =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 1 )
          , Alive
          )
        , ( ( 0, 2 )
          , Alive
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Alive
          )
        , ( ( 1, 2 )
          , Alive
          )
        , ( ( 2, 0 )
          , Alive
          )
        , ( ( 2, 1 )
          , Alive
          )
        , ( ( 2, 2 )
          , Alive
          )
        ]


largerGrid : Grid
largerGrid =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 1 )
          , Alive
          )
        , ( ( 0, 2 )
          , Alive
          )
        , ( ( 0, 3 )
          , Alive
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Alive
          )
        , ( ( 1, 2 )
          , Alive
          )
        , ( ( 1, 3 )
          , Alive
          )
        , ( ( 2, 0 )
          , Alive
          )
        , ( ( 2, 1 )
          , Alive
          )
        , ( ( 2, 2 )
          , Alive
          )
        , ( ( 2, 3 )
          , Alive
          )
        ]



--   [[Dead, Dead, Dead, Dead],
--    [Alive, Alive, Dead, Dead],
--    [Alive, Alive, Alive, Dead],
--    [Alive, Alive, Alive, Dead]])


exampleGridWithMix : Grid
exampleGridWithMix =
    Dict.fromList
        [ ( ( 0, 0 )
          , Dead
          )
        , ( ( 0, 1 )
          , Dead
          )
        , ( ( 0, 2 )
          , Dead
          )
        , ( ( 0, 3 )
          , Dead
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Alive
          )
        , ( ( 1, 2 )
          , Alive
          )
        , ( ( 1, 3 )
          , Dead
          )
        , ( ( 2, 0 )
          , Alive
          )
        , ( ( 2, 1 )
          , Alive
          )
        , ( ( 2, 2 )
          , Alive
          )
        , ( ( 2, 3 )
          , Dead
          )
        , ( ( 3, 0 )
          , Alive
          )
        , ( ( 3, 1 )
          , Alive
          )
        , ( ( 3, 2 )
          , Alive
          )
        , ( ( 3, 3 )
          , Dead
          )
        ]


suite : Test
suite =
    describe "model"
        [ describe "finding neighboring coords"
            [ test "with origin (0,0)" <|
                \_ ->
                    Expect.equal (findNeighboringCoords ( 0, 0 ))
                        [ ( -1, -1 )
                        , ( -1, 0 )
                        , ( -1, 1 )
                        , ( 0, -1 )
                        , ( 0, 1 )
                        , ( 1, -1 )
                        , ( 1, 0 )
                        , ( 1, 1 )
                        ]
            , test "upper left (-1,-1)" <|
                \_ ->
                    Expect.equal (findNeighboringCoords ( -1, -1 ))
                        [ ( -2, -2 )
                        , ( -2, -1 )
                        , ( -2, 0 )
                        , ( -1, -2 )
                        , ( -1, 0 )
                        , ( 0, -2 )
                        , ( 0, -1 )
                        , ( 0, 0 )
                        ]
            ]
        , describe "toCenter"
            [ test "square" <|
                \_ ->
                    Expect.equal (toCenter ( 3, 3 )) ( 1, 1 )
            , test "rectangle" <|
                \_ ->
                    Expect.equal (toCenter ( 3, 5 )) ( 1, 2 )
            ]
        , describe "create from a specific point"
            [ test "tiny" <|
                \_ ->
                    Expect.equal (createCellAndNeighbors ( 1, 1 ) ( 0, 0 ) Alive Dict.empty)
                        (Dict.fromList [ ( ( 0, 0 ), Alive ) ])
            , test "bitty" <|
                \_ ->
                    Expect.equal (createCellAndNeighbors ( 1, 2 ) ( 0, 0 ) Alive Dict.empty)
                        (Dict.fromList [ ( ( 0, 0 ), Alive ), ( ( 0, 1 ), Alive ) ])
            ]
        , describe "creating a grid"
            [ test "with all alive cells" <|
                \_ ->
                    Expect.equal (createGrid 3 3 Alive) exampleGrid
            , test "with more cells" <|
                \_ ->
                    Expect.equal (createGrid 3 4 Alive) largerGrid
            ]
        , describe "isAlive"
            [ test "an Alive cell is Alive" <|
                \_ ->
                    Expect.equal (isAlive Alive) True
            , test "a Dead cell is not Alive" <|
                \_ ->
                    Expect.equal (isAlive Dead) False
            ]
        , describe "getCell"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (getCell ( 0, 0 ) exampleGrid) (Just Alive)
            , test "second row, second column" <|
                \_ ->
                    Expect.equal (getCell ( 1, 1 ) exampleGrid) (Just Alive)
            , test "out of bounds" <|
                \_ ->
                    Expect.equal (getCell ( 42, 3432 ) exampleGrid) Nothing
            ]
        , describe "willBeAlive"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (willBeAlive Dead 2) False
            , test "second row, second column" <|
                \_ ->
                    Expect.equal (willBeAlive Alive 4) False
            , test "second row, third column" <|
                \_ ->
                    Expect.equal (willBeAlive Alive 3) True
            , test "out of bounds" <|
                \_ ->
                    Expect.equal (willBeAlive Alive 0) False
            ]
        , describe "getNeighbors"
            [ test "row 2, column 3" <|
                \_ ->
                    Expect.equal
                        (prep (getNeighbors ( 1, 2 ) exampleGridWithMix))
                        (prep [ Dead, Dead, Dead, Alive, Dead, Alive, Alive, Dead ])
            ]
        , describe "stepGrid"
            [ test "stepping a grid" <|
                \_ ->
                    Expect.equal (stepGrid smallerGrid) smallerGridNext
            ]
        , describe "toggleCell"
            [ test "kills a live cell" <|
                \_ ->
                    Expect.equal
                        (toggleCell ( 0, 0 ) Alive smallerGrid)
                        (Dict.fromList
                            [ ( ( 0, 0 )
                              , Dead
                              )
                            , ( ( 0, 1 )
                              , Alive
                              )
                            , ( ( 1, 0 )
                              , Alive
                              )
                            , ( ( 1, 1 )
                              , Alive
                              )
                            ]
                        )
            ]
        ]


prep : List Cell -> List Cell
prep list =
    List.sortBy cellToInt list


cellToInt : Cell -> Int
cellToInt cell =
    case cell of
        Alive ->
            1

        Dead ->
            0