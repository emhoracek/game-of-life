module Garden.ViewTests exposing (..)

import Garden.View exposing (..)
import Garden.Grid.Model exposing (CellState(..), Grid)
import Dict
import Expect
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

        -- , ( ( 3000, 301 )
        --   , Alive
        --   )
        ]


suite : Test
suite =
    describe "Game of Life"
        [ describe "toRows"
            [ test "converts grid to rows for display" <|
                \_ ->
                    Expect.equal
                        (toRows { rows = 2, columns = 3 } smallGrid)
                        [ [ Alive, Dead, Dead ]
                        , [ Alive, Alive, Dead ]
                        ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (toRows { rows = 3, columns = 3 } sparseGrid)
                        [ [ Alive, Dead, Alive ]
                        , [ Alive, Dead, Dead ]
                        , [ Dead, Dead, Dead ]
                        ]
            ]
        , describe "toColumns"
            [ test "converts row of grid to list of cells for display" <|
                \_ ->
                    Expect.equal
                        (toColumns 3 smallGrid 0)
                        [ Alive, Dead, Dead ]
            , test "sparse grid" <|
                \_ ->
                    Expect.equal
                        (toColumns 3 sparseGrid 0)
                        [ Alive, Dead, Alive ]
            ]
        ]
