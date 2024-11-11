module Garden.Display.Model exposing (..)

import Array exposing (Array)
import Dict
import Garden.Grid.Model exposing (CellState(..), Grid)
import Garden.Grid.Update exposing (defaultColumns, defaultRows)


type Plant
    = Blue
    | Pink
    | Purple
    | Yellow


type alias Display =
    { rows : Int
    , columns : Int
    , plants : Array Plant
    }


listDisplay : Grid -> Display -> List (List (Maybe Plant))
listDisplay grid display =
    List.foldr
        (\r rows ->
            List.foldr (\c cols -> toDisplayCell grid display r c :: cols)
                []
                (List.range 0 (display.columns - 1))
                :: rows
        )
        []
        (List.range 0 (display.rows - 1))


getPlant : Display -> Int -> Int -> Plant
getPlant display row col =
    Maybe.withDefault Blue (Array.get (row * col + col) display.plants)


toDisplayCell : Grid -> Display -> Int -> Int -> Maybe Plant
toDisplayCell grid display row col =
    case Dict.get ( row, col ) grid of
        Just Alive ->
            Just (getPlant display row col)

        _ ->
            Nothing


initGardenDisplay : Display
initGardenDisplay =
    { rows = defaultRows, columns = defaultColumns, plants = Array.fromList [] }


initNurseryDisplay : Display
initNurseryDisplay =
    { rows = defaultRows // 2, columns = defaultColumns // 2, plants = Array.fromList [] }
