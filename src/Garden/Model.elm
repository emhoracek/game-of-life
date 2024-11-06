module Garden.Model exposing (..)

import Garden.Grid.Model exposing (CellState(..), Grid)
import Garden.Grid.Update exposing (GridMsg(..))
import Dict exposing (Dict)

type alias Model =
    { grids : Dict GridId Grid
    , settings : GameSettings
    , timeInCycle : Int
    , animation : Maybe Int
    }


type alias GridId =
    String


type alias GameSettings =
    { rows : Int, columns : Int }


type Msg
    = NoOp
    | Increment
    | Decrement
    | Stop
    | Go
    | GridMsg GridId GridMsg


defaultTiming : Int
defaultTiming =
    100
