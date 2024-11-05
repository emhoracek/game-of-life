module CellTeams.CellTeamsTests exposing (..)

import CellTeams.CellTeams exposing (..)
import CellTeams.Grid.Model exposing (CellState(..), Grid)
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
          , Alive
          )
        , ( ( 1, 0 )
          , Alive
          )
        , ( ( 1, 1 )
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
                        (toRows { rows = 2, columns = 2 } smallGrid)
                        [ [ Alive, Alive ]
                        , [ Alive
                          , Alive
                          ]
                        ]
            ]
        ]
