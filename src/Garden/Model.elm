module Garden.Model exposing (..)

import Array exposing (Array)
import Garden.Display.Model exposing (Display, Plant)
import Garden.Grid.Model exposing (CellState(..), Grid)
import Garden.Grid.Update exposing (GridMsg(..))


type alias Model =
    { garden : Grid
    , nursery : Grid
    , gardenDisplay : Display
    , nurseryDisplay : Display
    , settings : GameSettings
    , timeInCycle : Int
    , animation : Maybe Int
    , plants : List (List Plant)
    }


type alias GameSettings =
    { rows : Int, columns : Int }


type GridName
    = Garden
    | Nursery


type Msg
    = NoOp
    | Increment
    | Decrement
    | Stop
    | Go
    | SetColors (Array Plant)
    | GridMsg GridName GridMsg


defaultTiming : Int
defaultTiming =
    100
