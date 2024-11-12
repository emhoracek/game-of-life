module Garden.Display.ModelTests exposing (..)

import Array
import Dict
import Expect
import Garden.Display.Model exposing (..)
import Garden.Grid.Model exposing (CellState(..), Grid, centerOf)
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
                            { area = { topLeft = ( 0, 0 ), bottomRight = ( 1, 2 ) }
                            , plants = Array.fromList [ Yellow, Purple, Pink, Blue ]
                            }
                    in
                    Expect.equal (getPlant display 0 1) Purple
            , test "outside bounds, returns default plant" <|
                \_ ->
                    let
                        display =
                            { area = { topLeft = ( 0, 0 ), bottomRight = ( 1, 2 ) }
                            , plants = Array.fromList [ Yellow, Purple, Pink, Pink ]
                            }
                    in
                    Expect.equal (getPlant display 3 3) Blue
            ]
        , describe "toPlants"
            [ test "shows display as rows of plants" <|
                \_ ->
                    Expect.equal
                        (listDisplay smallGrid { area = { topLeft = ( 0, 0 ), bottomRight = ( 1, 2 ) }, plants = Array.repeat 100 Blue })
                        [ [ Just Blue, Nothing, Nothing ]
                        , [ Just Blue, Just Blue, Nothing ]
                        ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (listDisplay sparseGrid { area = { topLeft = ( 0, 0 ), bottomRight = ( 2, 2 ) }, plants = Array.repeat 100 Blue })
                        [ [ Just Blue, Nothing, Just Blue ]
                        , [ Just Blue, Nothing, Nothing ]
                        , [ Nothing, Nothing, Nothing ]
                        ]
            ]
        , describe "centerOf"
            [ test "even grid" <|
                \_ -> Expect.equal (centerOf { topLeft = ( 0, 0 ), bottomRight = ( 2, 2 ) }) ( 1, 1 )
            , test "odd grid" <|
                \_ -> Expect.equal (centerOf { topLeft = ( 0, 0 ), bottomRight = ( 2, 3 ) }) ( 1, 2 )
            ]
        , describe "centerAt"
            [ test "even number rows and columns" <|
                \_ ->
                    Expect.equal (centerAt { area = { topLeft = ( 10, 10 ), bottomRight = ( 13, 13 ) }, plants = Array.empty } ( 1, 1 ))
                        { topLeft = ( 0, 0 )
                        , bottomRight = ( 3, 3 )
                        }
            , test "odd number rows and columns" <|
                \_ ->
                    Expect.equal (centerAt { area = { topLeft = ( 10, 10 ), bottomRight = ( 12, 12 ) }, plants = Array.empty } ( 1, 1 ))
                        { topLeft = ( 0, 0 )
                        , bottomRight = ( 2, 2 )
                        }
            ]
        ]
