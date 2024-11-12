module Garden.Grid.ModelTests exposing (..)

import Dict
import Expect
import Garden.Grid.Model exposing (..)
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


tinyGrid : Grid
tinyGrid =
    Dict.fromList
        [ ( ( 1, 1 )
          , Alive
          )
        ]



-- A A  -> A A
-- A       A A


sparseGrid1 : Grid
sparseGrid1 =
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
        ]


sparseGrid1Next : Grid
sparseGrid1Next =
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



-- A - A     A - D
-- A A - ->  A D A
-- - A -     A A -


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
        , ( ( 1, 1 )
          , Alive
          )
        , ( ( 2, 1 )
          , Alive
          )
        ]



-- A - A     A - D
-- A A - ->  A D A
-- - A -     A A -


sparseGridNext : Grid
sparseGridNext =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 2 )
          , Dead
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Dead
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
        ]


sparseGrid2 : Grid
sparseGrid2 =
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
        , ( ( 1, 1 )
          , Alive
          )
        , ( ( 2, 1 )
          , Alive
          )
        , ( ( 2000, 1000 )
          , Alive
          )
        ]


sparseGrid2Next : Grid
sparseGrid2Next =
    Dict.fromList
        [ ( ( 0, 0 )
          , Alive
          )
        , ( ( 0, 2 )
          , Dead
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
          , Dead
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
        , ( ( 2000, 1000 )
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
        , describe "isAlive"
            [ test "an Alive cell is Alive" <|
                \_ ->
                    Expect.equal (isAlive Alive) True
            , test "a Dead cell is not Alive" <|
                \_ ->
                    Expect.equal (isAlive Dead) False
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
            , test "stepping a sparse grid" <|
                \_ ->
                    Expect.equal (stepGrid sparseGrid2) sparseGrid2Next
            ]
        , describe "getBounds"
            [ test "tiny" <|
                \_ ->
                    Expect.equal (getBounds sparseGrid1) { topLeft = ( 0, 0 ), bottomRight = ( 1, 1 ) }
            , test "small" <|
                \_ ->
                    Expect.equal (getBounds sparseGrid) { topLeft = ( 0, 0 ), bottomRight = ( 2, 2 ) }
            ]
        , describe "dimensionsOf"
            [ test "one cell" <|
                \_ -> Expect.equal (dimensionsOf { topLeft = ( 0, 0 ), bottomRight = ( 0, 0 ) }) ( 1, 1 )
            , test "many cells" <|
                \_ -> Expect.equal (dimensionsOf { topLeft = ( 0, 0 ), bottomRight = ( 9, 9 ) }) ( 10, 10 )
            ]
        , describe "maybeUpdate"
            [ test "alive" <|
                \_ ->
                    Expect.equal (stepCell 2 (Just Alive)) (Just Alive)
            , test "dead with neighbors" <|
                \_ ->
                    Expect.equal (stepCell 3 (Just Dead)) (Just Alive)
            , test "nothing with neighbors" <|
                \_ ->
                    Expect.equal (stepCell 3 Nothing) (Just Alive)
            , test "dead without neighbors" <|
                \_ ->
                    Expect.equal (stepCell 1 (Just Dead)) Nothing
            , test "alive with too many neighbors" <|
                \_ ->
                    Expect.equal (stepCell 4 (Just Alive)) (Just Dead)
            ]
        , describe "listOfCellsToCheck"
            [ test "tiny grid" <|
                \_ ->
                    Expect.equalLists (List.sort (listOfCellsToUpdate tinyGrid))
                        [ ( 0, 0 ), ( 0, 1 ), ( 0, 2 ), ( 1, 0 ), ( 1, 1 ), ( 1, 2 ), ( 2, 0 ), ( 2, 1 ), ( 2, 2 ) ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equalLists (List.sort (listOfCellsToUpdate sparseGrid))
                        [ ( -1, -1 ), ( -1, 0 ), ( -1, 1 ), ( -1, 2 ), ( -1, 3 ), ( 0, -1 ), ( 0, 0 ), ( 0, 1 ), ( 0, 2 ), ( 0, 3 ), ( 1, -1 ), ( 1, 0 ), ( 1, 1 ), ( 1, 2 ), ( 1, 3 ), ( 2, -1 ), ( 2, 0 ), ( 2, 1 ), ( 2, 2 ), ( 3, 0 ), ( 3, 1 ), ( 3, 2 ) ]
            ]
        , describe "stepSparseGrid"
            [ test "an empty grid" <|
                \_ ->
                    Expect.equal (stepGrid Dict.empty) Dict.empty
            , test "a grid with one cell" <|
                \_ ->
                    Expect.equal (stepGrid (Dict.insert ( 1, 1 ) Alive Dict.empty))
                        (Dict.insert ( 1, 1 ) Dead Dict.empty)
            , test "a tiny grid" <|
                \_ ->
                    Expect.equal (stepGrid sparseGrid1) sparseGrid1Next
            , test "stepping a sparse grid" <|
                \_ ->
                    Expect.equal (stepGrid sparseGrid) sparseGridNext
            ]
        , describe "count living"
            [ test "an empty grid" <|
                \_ ->
                    Expect.equal (countLiving Dict.empty) 0
            , test "a grid with one cell" <|
                \_ ->
                    Expect.equal (countLiving (Dict.insert ( 1, 1 ) Alive Dict.empty)) 1
            , test "a small grid" <|
                \_ ->
                    Expect.equal (countLiving smallerGrid) 3
            , test "a sparse grid" <|
                \_ ->
                    Expect.equal (countLiving exampleGridWithMix) 9
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
        , describe "addSubGrid"
            [ test "adding an empty grid to an empty grid" <|
                \_ ->
                    let
                        garden =
                            Dict.empty

                        nursery =
                            Dict.empty

                        garden2 =
                            Dict.empty
                    in
                    Expect.equal (addSubGrid garden nursery) garden2
            , test "adding a single point to an empty grid" <|
                \_ ->
                    let
                        garden =
                            Dict.empty

                        nursery =
                            Dict.fromList [ ( ( 10, 10 ), Alive ) ]

                        garden2 =
                            Dict.fromList [ ( ( 10, 10 ), Alive ) ]
                    in
                    Expect.equal (addSubGrid garden nursery) garden2
            , test "adding a single point to a grid with a different point" <|
                \_ ->
                    let
                        garden =
                            Dict.fromList [ ( ( 1, 1 ), Alive ) ]

                        nursery =
                            Dict.fromList [ ( ( 10, 10 ), Alive ) ]

                        garden2 =
                            Dict.fromList [ ( ( 1, 1 ), Alive ), ( ( 10, 10 ), Alive ) ]
                    in
                    Expect.equal (addSubGrid garden nursery) garden2
            , test "adding two grids, add any live nursery cells" <|
                \_ ->
                    let
                        garden =
                            Dict.fromList [ ( ( 1, 1 ), Dead ) ]

                        nursery =
                            Dict.fromList [ ( ( 1, 1 ), Alive ) ]

                        garden2 =
                            Dict.fromList [ ( ( 1, 1 ), Alive ) ]
                    in
                    Expect.equal (addSubGrid garden nursery) garden2
            , test "adding two grids, don't include dead nursery cells" <|
                \_ ->
                    let
                        garden =
                            Dict.fromList [ ( ( 1, 1 ), Alive ) ]

                        nursery =
                            Dict.fromList [ ( ( 1, 1 ), Dead ) ]

                        garden2 =
                            Dict.fromList [ ( ( 1, 1 ), Alive ) ]
                    in
                    Expect.equal (addSubGrid garden nursery) garden2
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
