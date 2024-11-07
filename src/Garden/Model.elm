module Garden.Model exposing (..)

import Dict exposing (Dict)
import Garden.Grid.Model exposing (CellState(..), Grid)
import Garden.Grid.Update exposing (GridMsg(..))


type alias Model =
    { grids : Dict GridId Grid
    , settings : GameSettings
    , timeInCycle : Int
    , animation : Maybe Int
    , plants : List (List Plant)
    }


type alias GridId =
    String


type alias GameSettings =
    { rows : Int, columns : Int }


type Plant
    = Blue
    | Pink
    | Purple
    | Yellow


type alias DisplayGrid =
    List (List (Maybe Plant))


type Msg
    = NoOp
    | Increment
    | Decrement
    | Stop
    | Go
    | SetColors (List (List Plant))
    | GridMsg GridId GridMsg


defaultTiming : Int
defaultTiming =
    100
