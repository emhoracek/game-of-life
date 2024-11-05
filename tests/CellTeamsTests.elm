module CellTeamsTests exposing (..)

import Dict
import Expect
import List exposing ((::))
import Test exposing (Test, describe, test)

import CellTeams exposing (..)


exampleCell : Cell
exampleCell =
    { 
      state = Alive
    }


smallerGrid1 : Grid
smallerGrid1 =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
            ,   {
                 state = Alive
                }
              )
            , ( ( 0, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 1 )
              , { 
                  state = Alive
                }
              )
            ]
    }


exampleGrid : Grid
exampleGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 0, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 0, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 2 )
              , { 
                  state = Alive
                }
              )
            ]
    }


largerGrid : Grid
largerGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 0, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 0, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 0, 3 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 3 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 3 )
              , { 
                  state = Alive
                }
              )
            ]
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
              , { 
                  state = Dead
                }
              )
            , ( ( 0, 1 )
              , { 
                  state = Dead
                }
              )
            , ( ( 0, 2 )
              , { 
                  state = Dead
                }
              )
            , ( ( 0, 3 )
              , { 
                  state = Dead
                }
              )
            , ( ( 1, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 1, 3 )
              , { 
                  state = Dead
                }
              )
            , ( ( 2, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 2, 3 )
              , { 
                  state = Dead
                }
              )
            , ( ( 3, 0 )
              , { 
                  state = Alive
                }
              )
            , ( ( 3, 1 )
              , { 
                  state = Alive
                }
              )
            , ( ( 3, 2 )
              , { 
                  state = Alive
                }
              )
            , ( ( 3, 3 )
              , { 
                  state = Dead
                }
              )
            ]
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
                        (Dict.fromList [ ( ( 0, 0 ), Cell Alive ) ])
            , test "bitty" <|
                \_ ->
                    Expect.equal (createCellAndNeighbors ( 1, 2 ) ( 0, 0 ) Alive Dict.empty)
                        (Dict.fromList [ ( ( 0, 0 ), Cell Alive ), ( ( 0, 1 ), Cell Alive ) ])
            ]
        , test "bigger" <|
            \_ ->
                Expect.equal (createCellAndNeighbors ( 2, 2 ) ( 0, 0 ) Alive Dict.empty) smallerGrid1.cells
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
                    Expect.equal (isAlive (Cell Alive)) True
            , test "a Dead cell is not Alive" <|
                \_ ->
                    Expect.equal (isAlive (Cell Dead)) False
            ]
        , describe "getCell"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (getCell ( 0, 0 ) exampleGrid) (Just (Cell Alive))
            , test "second row, second column" <|
                \_ ->
                    Expect.equal (getCell ( 1, 1 ) exampleGrid) (Just (Cell Alive))
            , test "out of bounds" <|
                \_ ->
                    Expect.equal (getCell ( 42, 3432 ) exampleGrid) Nothing
            ]
        , describe "willBeAlive"
            [ test "upper left" <|
                \_ ->
                    Expect.equal (willBeAlive (Cell Dead) 2) False
            , test "second row, second column" <|
                \_ ->
                    Expect.equal (willBeAlive (Cell Alive) 4) False
            , test "second row, third column" <|
                \_ ->
                    Expect.equal (willBeAlive (Cell Alive) 3) True
            , test "out of bounds" <|
                \_ ->
                    Expect.equal (willBeAlive (Cell Alive) 0) False
            ]
        , describe "getNeighbors"
            [ test "row 2, column 3" <|
                \_ ->
                    Expect.equal
                        (prep (getNeighbors (1, 2) exampleGridWithMix))
                        (prep [ Cell Dead, Cell Dead, Cell Dead, Cell Alive, Cell Dead, Cell Alive, Cell Alive, Cell Dead ])
            ]
        , describe "toRows"
            [ test "converts grid to rows for display" <|
                \_ ->
                    Expect.equal
                        (toRows { rows = 2, columns = 2 } smallerGrid1)
                        [ [ { state = Alive }
                          , { 
                              state = Alive
                            }
                          ]
                        , [ { 
                              state = Alive
                            }
                          , { 
                              state = Alive
                            }
                          ]
                        ]
            ], 
            describe "toggleCell"
            [ test "kills a live cell" <|
                \_ ->
                    Expect.equal
                        (toggleCell (0,0) (Cell Alive) smallerGrid1)
                            ({ cells = Dict.fromList
                                    [ ( ( 0, 0 )
                                    , { 
                                          state = Dead
                                        }
                                    )
                                    , ( ( 0, 1 )
                                    , { 
                                          state = Alive
                                        }
                                    )
                                    , ( ( 1, 0 )
                                    , { 
                                          state = Alive
                                        }
                                    )
                                    , ( ( 1, 1 )
                                    , { 
                                          state = Alive
                                        }
                                    )
                                    ]})
            ]
        ]


prep : List Cell -> List Cell
prep list =
    List.sortBy (cellToInt) list


cellToInt : Cell -> Int
cellToInt cell =
    case cell.state of
        Alive ->
            1

        Dead ->
            0