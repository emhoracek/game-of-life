module Garden.Display.ModelTests exposing (..)

import Array
import Dict
import Expect
import Garden.Display.Model exposing (..)
import Garden.Grid.Model exposing (CellState(..), Grid)
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
        [ describe "getPlant"
            [ test "inside bounds, returns a plant" <|
                \_ ->
                    let
                        display =
                            { rows = 2
                            , columns = 3
                            , plants = Array.fromList [ Yellow, Purple, Pink, Blue ]
                            }
                    in
                    Expect.equal (getPlant display 0 1) Purple
            , test "outside bounds, returns default plant" <|
                \_ ->
                    let
                        display =
                            { rows = 2
                            , columns = 3
                            , plants = Array.fromList [ Yellow, Purple, Pink, Pink ]
                            }
                    in
                    Expect.equal (getPlant display 3 3) Blue
            ]
        , describe "toPlants"
            [ test "shows display as rows of plants" <|
                \_ ->
                    Expect.equal
                        (listDisplay smallGrid { rows = 2, columns = 3, plants = Array.repeat 100 Blue })
                        [ [ Just Blue, Nothing, Nothing ]
                        , [ Just Blue, Just Blue, Nothing ]
                        ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (listDisplay sparseGrid { rows = 3, columns = 3, plants = Array.repeat 100 Blue })
                        [ [ Just Blue, Nothing, Just Blue ]
                        , [ Just Blue, Nothing, Nothing ]
                        , [ Nothing, Nothing, Nothing ]
                        ]
            ]
        ]
