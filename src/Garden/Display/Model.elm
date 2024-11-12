module Garden.Display.Model exposing (..)

import Array exposing (Array)
import Dict
import Garden.Grid.Model exposing (Area, CellState(..), Direction, Grid, dimensionsOf, moveArea)
import Garden.Grid.Update exposing (defaultColumns, defaultRows)
import Random exposing (Generator)


type Plant
    = Blue
    | Pink
    | Purple
    | Yellow


type alias Display =
    { area : Area
    , plants : Array Plant
    }


centerAt : Display -> ( Int, Int ) -> Area
centerAt display ( r, c ) =
    let
        ( height, width ) =
            Tuple.mapBoth (\h -> h - 1) (\w -> w - 1) (dimensionsOf display.area)

        aboveCenter =
            height // 2

        belowCenter =
            (height // 2) + remainderBy 2 height

        leftOfCenter =
            width // 2

        rightOfCenter =
            width // 2 + remainderBy 2 height
    in
    { topLeft = ( r - aboveCenter, c - leftOfCenter )
    , bottomRight = ( r + belowCenter, c + rightOfCenter )
    }


listDisplay : Grid -> Display -> List (List (Maybe Plant))
listDisplay grid display =
    let
        ( minR, minC ) =
            display.area.topLeft

        ( maxR, maxC ) =
            display.area.bottomRight
    in
    List.foldr
        (\r rows ->
            List.foldr (\c cols -> toDisplayCell grid display r c :: cols)
                []
                (List.range minC maxC)
                :: rows
        )
        []
        (List.range minR maxR)


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
    { area = { topLeft = ( 0, 0 ), bottomRight = ( defaultRows - 1, defaultColumns - 1 ) }, plants = Array.fromList [] }


initNurseryDisplay : Display
initNurseryDisplay =
    { area = { topLeft = ( 0, 0 ), bottomRight = ( (defaultRows // 2) - 1, (defaultColumns // 2) - 1 ) }, plants = Array.fromList [] }


randomColors : Int -> Int -> Generator (List Plant)
randomColors r c =
    Random.list (r * c) (Random.uniform Blue [ Pink, Purple, Yellow ])


moveDisplay : Display -> Direction -> Display
moveDisplay display dir =
    { area = moveArea dir display.area, plants = display.plants }
