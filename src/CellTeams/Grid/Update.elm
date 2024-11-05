module CellTeams.Grid.Update exposing (..)

import CellTeams.Grid.Model exposing (Cell, CellCoords, Grid, toggleCell, usuallyAlive)
import Random


type GridMsg
    = NoOp
    | NewGrid Grid
    | MkNewGrid
    | ToggleCell CellCoords Cell


defaultRows : Int
defaultRows =
    20


defaultColumns : Int
defaultColumns =
    20


makeGrid : Cmd GridMsg
makeGrid =
    Random.generate NewGrid (usuallyAlive ( defaultRows, defaultColumns ))


updateGrid : GridMsg -> Grid -> ( Grid, Cmd GridMsg )
updateGrid msg grid =
    case msg of
        NoOp ->
            ( grid, Cmd.none )

        MkNewGrid ->
            ( grid, makeGrid )

        NewGrid newGrid ->
            ( newGrid, Cmd.none )

        ToggleCell coords cell ->
            ( toggleCell coords cell grid, Cmd.none )
