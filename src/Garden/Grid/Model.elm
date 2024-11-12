module Garden.Grid.Model exposing (..)

import Dict exposing (Dict)
import Html exposing (a)
import Html.Attributes exposing (coords)
import List
import Random


type CellState
    = Alive
    | Dead


type alias CellCoords =
    ( Int, Int )


type alias Cell =
    CellState


type alias Grid =
    Dict CellCoords Cell


type alias Area =
    { topLeft : ( Int, Int )
    , bottomRight : ( Int, Int )
    }


dimensionsOf : Area -> ( Int, Int )
dimensionsOf area =
    let
        ( r1, c1 ) =
            area.topLeft

        ( r2, c2 ) =
            area.bottomRight
    in
    ( r2 - r1 + 1, c2 - c1 + 1 )


centerOf : Area -> ( Int, Int )
centerOf area =
    let
        ( rows, cols ) =
            dimensionsOf area

        ( r1, c1 ) =
            area.topLeft
    in
    ( (rows // 2) + r1, (cols // 2) + c1 )


toCenter : ( Int, Int ) -> CellCoords
toCenter ( rows, cols ) =
    ( floor (toFloat rows / 2), floor (toFloat cols / 2) )


findNeighboringCoords : CellCoords -> List CellCoords
findNeighboringCoords ( row, col ) =
    let
        arr =
            [ ( -1, -1 )
            , ( -1, 0 )
            , ( -1, 1 )
            , ( 0, -1 )
            , ( 0, 1 )
            , ( 1, -1 )
            , ( 1, 0 )
            , ( 1, 1 )
            ]
    in
    List.foldr (\( rowOff, colOff ) acc -> ( row + rowOff, col + colOff ) :: acc) [] arr


createCellAndNeighbors : ( Int, Int ) -> CellCoords -> CellState -> Dict CellCoords Cell -> Dict CellCoords Cell
createCellAndNeighbors ( r, c ) ( a, b ) state cells =
    List.foldr
        (\( a2, b2 ) acc ->
            if a2 < r && b2 < c && a2 >= 0 && b2 >= 0 then
                createCellAndNeighbors ( r, c ) ( a2, b2 ) state acc

            else
                acc
        )
        (Dict.insert ( a, b ) state cells)
        (List.filter (\coords -> Dict.get coords cells == Nothing) (findNeighboringCoords ( a, b )))


usuallyDeadCell : Random.Generator CellState
usuallyDeadCell =
    Random.weighted ( 40, Alive ) [ ( 60, Dead ) ]


listToIndexedList : Int -> List CellState -> List ( ( Int, Int ), Cell )
listToIndexedList cols cells =
    List.indexedMap
        (\n state ->
            let
                row =
                    n // cols

                col =
                    modBy cols n

                coords =
                    ( row, col )
            in
            ( coords, state )
        )
        cells


usuallyAlive : ( Int, Int ) -> Random.Generator Grid
usuallyAlive ( rows, columns ) =
    Random.map
        (\l -> Dict.fromList (listToIndexedList columns l))
        (Random.list (rows * columns) usuallyDeadCell)


getNeighbors : CellCoords -> Grid -> List Cell
getNeighbors coords grid =
    List.filterMap (\c -> Dict.get c grid) (findNeighboringCoords coords)


isAlive : Cell -> Bool
isAlive cell =
    if cell == Alive then
        True

    else
        False


aliveNeighbors : CellCoords -> Grid -> Int
aliveNeighbors coords grid =
    List.length (List.filter isAlive (getNeighbors coords grid))


stepGrid : Grid -> Grid
stepGrid grid =
    let
        cellsToUpdate =
            listOfCellsToUpdate grid
    in
    updateCells grid cellsToUpdate


toggleState : CellState -> CellState
toggleState state =
    if state == Alive then
        Dead

    else
        Alive


toggleCell : CellCoords -> Cell -> Grid -> Grid
toggleCell coords cell grid =
    Dict.insert coords (toggleState cell) grid


stepCell : Int -> Maybe Cell -> Maybe Cell
stepCell neighborCount mCell =
    case mCell of
        Just Alive ->
            if neighborCount == 2 || neighborCount == 3 then
                Just Alive

            else
                Just Dead

        _ ->
            if neighborCount == 3 then
                Just Alive

            else
                Nothing


getBounds : Grid -> Area
getBounds grid =
    let
        liveCoords =
            Dict.keys (Dict.filter (\_ v -> v == Alive) grid)

        rowsLowToHigh =
            List.sort (List.map Tuple.first liveCoords)

        colsLowToHigh =
            List.sort (List.map Tuple.second liveCoords)

        minRow =
            Maybe.withDefault 0 (List.head rowsLowToHigh)

        maxRow =
            Maybe.withDefault 0 (List.head (List.reverse rowsLowToHigh))

        minCol =
            Maybe.withDefault 0 (List.head colsLowToHigh)

        maxCol =
            Maybe.withDefault 0 (List.head (List.reverse colsLowToHigh))
    in
    { topLeft = ( minRow, minCol )
    , bottomRight = ( maxRow, maxCol )
    }


listOfCellsToUpdate : Grid -> List CellCoords
listOfCellsToUpdate grid =
    let
        liveCoords =
            Dict.keys grid

        allCellsAndNeighbors =
            List.concatMap (\k -> k :: findNeighboringCoords k) liveCoords
    in
    nub allCellsAndNeighbors


updateState : CellCoords -> Grid -> Maybe Cell
updateState coords grid =
    let
        mCell =
            Dict.get coords grid

        neighborCount =
            aliveNeighbors coords grid
    in
    stepCell neighborCount mCell


updateCells : Grid -> List CellCoords -> Grid
updateCells beforeUpdate cellsToUpdate =
    List.foldl (updateOne beforeUpdate) Dict.empty cellsToUpdate


updateOne : Grid -> CellCoords -> Grid -> Grid
updateOne oldGrid coords newGrid =
    let
        newCell =
            updateState coords oldGrid
    in
    maybeInsert coords newCell newGrid


countLiving : Grid -> Int
countLiving =
    Dict.foldl
        (\_ cell acc ->
            if isAlive cell then
                acc + 1

            else
                acc
        )
        0


addSubGrid : Grid -> Grid -> Grid
addSubGrid main toAdd =
    Dict.union (Dict.filter (\_ v -> v == Alive) main) toAdd



-- Utils


maybeInsert : comparable -> Maybe b -> Dict comparable b -> Dict comparable b
maybeInsert k maybeV dict =
    case maybeV of
        Just val ->
            Dict.insert k val dict

        Nothing ->
            dict


nub : List a -> List a
nub =
    List.foldl
        (\a acc ->
            if List.member a acc then
                acc

            else
                a :: acc
        )
        []
