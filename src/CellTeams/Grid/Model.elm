module CellTeams.Grid.Model exposing (..)

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


createGrid : Int -> Int -> CellState -> Grid
createGrid r c state =
    createCellAndNeighbors ( r, c ) (toCenter ( r, c )) state Dict.empty


cellToInt : Cell -> Int
cellToInt cell =
    case cell of
        Alive ->
            1

        Dead ->
            0


usuallyAliveCell : Random.Generator CellState
usuallyAliveCell =
    Random.weighted ( 50, Alive ) [ ( 50, Dead ) ]


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
        (Random.list (rows * columns) usuallyAliveCell)


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


deadGrid : Int -> Int -> Grid
deadGrid rows cols =
    createGrid rows cols Dead


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


getBounds : Grid -> ( ( Int, Int ), ( Int, Int ) )
getBounds grid =
    let
        rowsLowToHigh =
            List.sort (List.map Tuple.first (Dict.keys grid))

        colsLowToHigh =
            List.sort (List.map Tuple.second (Dict.keys grid))

        minRow =
            max (Maybe.withDefault 0 (List.head rowsLowToHigh)) -5

        maxRow =
            min (Maybe.withDefault 0 (List.head (List.reverse rowsLowToHigh))) 20

        minCol =
            max (Maybe.withDefault 0 (List.head colsLowToHigh)) -5

        maxCol =
            min (Maybe.withDefault 0 (List.head (List.reverse colsLowToHigh))) 20
    in
    ( ( minRow, minCol ), ( maxRow, maxCol ) )


getCenter : ( Int, Int ) -> ( Int, Int ) -> CellCoords
getCenter ( row1, col1 ) ( row2, col2 ) =
    ( row2 - row1 // 2, col2 - col1 // 2 )


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
