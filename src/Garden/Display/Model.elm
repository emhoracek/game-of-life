module Garden.Display.Model exposing (..)

import Array exposing (Array)
import Dict
import Garden.Grid.Model exposing (CellState(..), Grid)


type alias Display =
    { rows : Int
    , columns : Int
    , plants : Array Plant
    , grid : Grid
    }


type Plant
    = Blue
    | Pink
    | Purple
    | Yellow


listDisplay : Display -> List (List (Maybe Plant))
listDisplay display =
    List.foldr
        (\r rows ->
            List.foldr (\c cols -> toDisplayCell display r c :: cols)
                []
                (List.range 0 (display.columns - 1))
                :: rows
        )
        []
        (List.range 0 (display.rows - 1))


getPlant : Display -> Int -> Int -> Plant
getPlant display row col =
    Maybe.withDefault Blue (Array.get (row * col + col) display.plants)


toDisplayCell : Display -> Int -> Int -> Maybe Plant
toDisplayCell display row col =
    case Dict.get ( row, col ) display.grid of
        Just Alive ->
            Just (getPlant display row col)

        _ ->
            Nothing
