module CellTeams.Grid.Model exposing (..)

import Dict exposing (Dict)
import List
import Random


type CellState
    = Alive
    | Dead


type alias CellCoords =
    ( Int, Int )


type alias Cell =
    { state : CellState
    }


type alias Grid =
    { cells : Dict CellCoords Cell
    }


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
        (Dict.insert ( a, b ) (Cell state) cells)
        (List.filter (\coords -> Dict.get coords cells == Nothing) (findNeighboringCoords ( a, b )))


createGrid : Int -> Int -> CellState -> Grid
createGrid r c state =
    { cells = createCellAndNeighbors ( r, c ) (toCenter ( r, c )) state Dict.empty
    }


cellToInt : Cell -> Int
cellToInt cell =
    case cell.state of
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
            ( coords, Cell state )
        )
        cells


usuallyAlive : ( Int, Int ) -> Random.Generator Grid
usuallyAlive ( rows, columns ) =
    Random.map
        (\l -> Grid (Dict.fromList (listToIndexedList columns l)))
        (Random.list (rows * columns) usuallyAliveCell)


getCell : CellCoords -> Grid -> Maybe Cell
getCell c grid =
    Dict.get c grid.cells


getNeighbors : CellCoords -> Grid -> List Cell
getNeighbors coords grid =
    List.filterMap (\c -> getCell c grid) (findNeighboringCoords coords)


isAlive : Cell -> Bool
isAlive cell =
    if cell.state == Alive then
        True

    else
        False


aliveNeighbors : CellCoords -> Grid -> Int
aliveNeighbors coords grid =
    List.length (List.filter isAlive (getNeighbors coords grid))


willBeAlive : Cell -> Int -> Bool
willBeAlive c liveNeighbors =
    if isAlive c then
        liveNeighbors
            == 2
            || liveNeighbors
            == 3

    else
        liveNeighbors == 3


updateCell : CellCoords -> Cell -> Grid -> Cell
updateCell coords cell grid =
    if willBeAlive cell (aliveNeighbors coords grid) then
        Cell Alive

    else
        Cell Dead


stepGrid : Grid -> Grid
stepGrid grid =
    { cells = Dict.foldr (\k c acc -> Dict.insert k (updateCell k c grid) acc) grid.cells grid.cells
    }


toggleState : CellState -> CellState
toggleState state =
    if state == Alive then
        Dead

    else
        Alive


toggleCell : CellCoords -> Cell -> Grid -> Grid
toggleCell coords cell grid =
    { cells = Dict.insert coords (Cell (toggleState cell.state)) grid.cells
    }


deadGrid : Int -> Int -> Grid
deadGrid rows cols =
    createGrid rows cols Dead
