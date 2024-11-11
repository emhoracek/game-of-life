module Garden.Model exposing (..)

import Array exposing (Array)
import Dict
import Garden.Display.Model exposing (Display, Plant)
import Garden.Grid.Model exposing (CellState(..), Grid)
import Garden.Grid.Update exposing (GridMsg(..))


type alias Model =
    { garden : Grid
    , nursery : Grid
    , gardenDisplay : Display
    , nurseryDisplay : Display
    , timeInCycle : Int
    , animation : Maybe Int
    }


type GridName
    = Garden
    | Nursery


type Msg
    = NoOp
    | Increment
    | Decrement
    | Stop
    | Go
    | AddNursery
    | SetColors (Array Plant)
    | GridMsg GridName GridMsg


defaultTiming : Int
defaultTiming =
    100
