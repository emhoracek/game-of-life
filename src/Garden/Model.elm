module Garden.Model exposing (..)

import Array exposing (Array)
import Dict
import Garden.Display.Model exposing (Display, Plant, centerOf)
import Garden.Grid.Model exposing (Area, CellState(..), Grid)
import Garden.Grid.Update exposing (GridMsg(..))


type alias Model =
    { garden : Grid
    , nursery : Grid
    , gardenDisplay : Display
    , nurseryDisplay : Display
    , nurseryTarget : Area
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


moveVisibleGrid : Grid -> Display -> Display -> Grid
moveVisibleGrid grid oldDisplay newDisplay =
    let
        ( currR, currC ) =
            centerOf oldDisplay

        ( newR, newC ) =
            centerOf newDisplay

        ( diffR, diffC ) =
            ( newR - currR, newC - currC )
    in
    Dict.foldr
        (\( r, c ) v acc ->
            Dict.insert ( r + diffR, c + diffC ) v acc
        )
        Dict.empty
        grid
