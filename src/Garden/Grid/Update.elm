module Garden.Grid.Update exposing (..)

import Garden.Grid.Model exposing (Cell, CellCoords, Grid, toggleCell, usuallyAlive)
import Random


type GridMsg
    = NoOp
    | NewGrid Grid
    | MkNewGrid (Int, Int)
    | ToggleCell CellCoords Cell


defaultRows : Int
defaultRows =
    20


defaultColumns : Int
defaultColumns =
    20


makeGrid : Int -> Int -> Cmd GridMsg
makeGrid rows cols =
    Random.generate NewGrid (usuallyAlive ( rows, cols ))


updateGrid : GridMsg -> Grid -> ( Grid, Cmd GridMsg )
updateGrid msg grid =
    case msg of
        NoOp ->
            ( grid, Cmd.none )

        MkNewGrid (rows, cols) ->
            ( grid, makeGrid rows cols )

        NewGrid newGrid ->
            ( newGrid, Cmd.none )

        ToggleCell coords cell ->
            ( toggleCell coords cell grid, Cmd.none )
