module TakeTwoTests exposing (..)

import Array
import Dict exposing (Dict)
import Expect
import List exposing ((::))
import TakeTwo exposing (..)
import Test exposing (Test, describe, test)


exampleCell : Cell
exampleCell =
    { coords = ( 0, 0 )
    , state = Alive
    }


smallerGrid : Grid
smallerGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { coords = ( 0, 0 )
                , state = Alive
                }
              )
            , ( ( 0, 1 )
              , { coords = ( 0, 1 )
                , state = Alive
                }
              )
            , ( ( 1, 0 )
              , { coords = ( 1, 0 )
                , state = Alive
                }
              )
            , ( ( 1, 1 )
              , { coords = ( 1, 1 )
                , state = Alive
                }
              )
            ]
    , rows = 2
    , columns = 2
    }


exampleGrid : Grid
exampleGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { coords = ( 0, 0 )
                , state = Alive
                }
              )
            , ( ( 0, 1 )
              , { coords = ( 0, 1 )
                , state = Alive
                }
              )
            , ( ( 0, 2 )
              , { coords = ( 0, 2 )
                , state = Alive
                }
              )
            , ( ( 1, 0 )
              , { coords = ( 1, 0 )
                , state = Alive
                }
              )
            , ( ( 1, 1 )
              , { coords = ( 1, 1 )
                , state = Alive
                }
              )
            , ( ( 1, 2 )
              , { coords = ( 1, 2 )
                , state = Alive
                }
              )
            , ( ( 2, 0 )
              , { coords = ( 2, 0 )
                , state = Alive
                }
              )
            , ( ( 2, 1 )
              , { coords = ( 2, 1 )
                , state = Alive
                }
              )
            , ( ( 2, 2 )
              , { coords = ( 2, 2 )
                , state = Alive
                }
              )
            ]
    , rows = 3
    , columns = 3
    }


largerGrid : Grid
largerGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { coords = ( 0, 0 )
                , state = Alive
                }
              )
            , ( ( 0, 1 )
              , { coords = ( 0, 1 )
                , state = Alive
                }
              )
            , ( ( 0, 2 )
              , { coords = ( 0, 2 )
                , state = Alive
                }
              )
            , ( ( 0, 3 )
              , { coords = ( 0, 3 )
                , state = Alive
                }
              )
            , ( ( 1, 0 )
              , { coords = ( 1, 0 )
                , state = Alive
                }
              )
            , ( ( 1, 1 )
              , { coords = ( 1, 1 )
                , state = Alive
                }
              )
            , ( ( 1, 2 )
              , { coords = ( 1, 2 )
                , state = Alive
                }
              )
            , ( ( 1, 3 )
              , { coords = ( 1, 3 )
                , state = Alive
                }
              )
            , ( ( 2, 0 )
              , { coords = ( 2, 0 )
                , state = Alive
                }
              )
            , ( ( 2, 1 )
              , { coords = ( 2, 1 )
                , state = Alive
                }
              )
            , ( ( 2, 2 )
              , { coords = ( 2, 2 )
                , state = Alive
                }
              )
            , ( ( 2, 3 )
              , { coords = ( 2, 3 )
                , state = Alive
                }
              )
            ]
    , rows = 3
    , columns = 4
    }



--   [[Dead, Dead, Dead, Dead],
--    [Alive, Alive, Dead, Dead],
--    [Alive, Alive, Alive, Dead],
--    [Alive, Alive, Alive, Dead]])


exampleGridWithMix : Grid
exampleGridWithMix =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { coords = ( 0, 0 )
                , state = Dead
                }
              )
            , ( ( 0, 1 )
              , { coords = ( 0, 1 )
                , state = Dead
                }
              )
            , ( ( 0, 2 )
              , { coords = ( 0, 2 )
                , state = Dead
                }
              )
            , ( ( 0, 3 )
              , { coords = ( 0, 3 )
                , state = Dead
                }
              )
            , ( ( 1, 0 )
              , { coords = ( 1, 0 )
                , state = Alive
                }
              )
            , ( ( 1, 1 )
              , { coords = ( 1, 1 )
                , state = Alive
                }
              )
            , ( ( 1, 2 )
              , { coords = ( 1, 2 )
                , state = Alive
                }
              )
            , ( ( 1, 3 )
              , { coords = ( 1, 3 )
                , state = Dead
                }
              )
            , ( ( 2, 0 )
              , { coords = ( 2, 0 )
                , state = Alive
                }
              )
            , ( ( 2, 1 )
              , { coords = ( 2, 1 )
                , state = Alive
                }
              )
            , ( ( 2, 2 )
              , { coords = ( 2, 2 )
                , state = Alive
                }
              )
            , ( ( 2, 3 )
              , { coords = ( 2, 3 )
                , state = Dead
                }
              )
            , ( ( 3, 0 )
              , { coords = ( 3, 0 )
                , state = Alive
                }
              )
            , ( ( 3, 1 )
              , { coords = ( 3, 1 )
                , state = Alive
                }
              )
            , ( ( 3, 2 )
              , { coords = ( 3, 2 )
                , state = Alive
                }
              )
            , ( ( 3, 3 )
              , { coords = ( 3, 3 )
                , state = Dead
                }
              )
            ]
    , rows = 4
    , columns = 4
    }


suite : Test
suite =
    describe "Game of Life"
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
                        (Dict.fromList [ ( ( 0, 0 ), Cell ( 0, 0 ) Alive ) ])
            , test "bitty" <|
                \_ ->
                    Expect.equal (createCellAndNeighbors ( 1, 2 ) ( 0, 0 ) Alive Dict.empty)
                        (Dict.fromList [ ( ( 0, 0 ), Cell ( 0, 0 ) Alive ), ( ( 0, 1 ), Cell ( 0, 1 ) Alive ) ])
            ]
        , test "bigger" <|
            \_ ->
                Expect.equal (createCellAndNeighbors ( 2, 2 ) ( 0, 0 ) Alive Dict.empty) smallerGrid.cells
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
                    Expect.equal (isAlive (Just (Cell ( 0, 0 ) Alive))) True
            , test "a Dead cell is not Alive" <|
                \_ ->
                    Expect.equal (isAlive (Just (Cell ( 0, 0 ) Dead))) False
            , test "an Nothing cell is Dead" <|
                \_ ->
                    Expect.equal (isAlive Nothing) False
            ]
        , describe "getCell"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (getCell ( 0, 0 ) exampleGrid) (Just (Cell ( 0, 0 ) Alive))
            , test "second row, second column" <|
                \_ ->
                    Expect.equal (getCell ( 1, 1 ) exampleGrid) (Just (Cell ( 1, 1 ) Alive))
            , test "out of bounds" <|
                \_ ->
                    Expect.equal (getCell ( 42, 3432 ) exampleGrid) Nothing
            ]
        , describe "willBeAlive"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (willBeAlive ( 0, 0 ) exampleGridWithMix) False
            , test "second row, second column" <|
                \_ ->
                    Expect.equal (willBeAlive ( 1, 1 ) exampleGridWithMix) False
            , test "second row, third column" <|
                \_ ->
                    Expect.equal (willBeAlive ( 1, 2 ) exampleGridWithMix) True
            , test "out of bounds" <|
                \_ ->
                    Expect.equal (willBeAlive ( 454, 1234 ) exampleGridWithMix) False
            ]
        , describe "getNeighbors"
            [ test "row 2, column 3" <|
                \_ ->
                    Expect.equal
                        (prep (getNeighbors ( 1, 2 ) exampleGridWithMix))
                        (prep [ Just (Cell ( 0, 1 ) Dead), Just (Cell ( 0, 2 ) Dead), Just (Cell ( 0, 3 ) Dead), Just (Cell ( 1, 1 ) Alive), Just (Cell ( 1, 3 ) Dead), Just (Cell ( 2, 1 ) Alive), Just (Cell ( 2, 2 ) Alive), Just (Cell ( 2, 3 ) Dead) ])
            ]
        , describe "toRows"
            [ test "converts grid to rows for display" <|
                \_ ->
                    Expect.equal
                        (toRows smallerGrid)
                        [ [ { coords = ( 0, 0 ), state = Alive }
                          , { coords = ( 0, 1 )
                            , state = Alive
                            }
                          ]
                        , [ { coords = ( 1, 0 )
                            , state = Alive
                            }
                          , { coords = ( 1, 1 )
                            , state = Alive
                            }
                          ]
                        ]
            ]
        ]


prep : List (Maybe Cell) -> List Cell
prep list =
    List.sortBy (\a -> a.coords) (List.filterMap (\a -> a) list)