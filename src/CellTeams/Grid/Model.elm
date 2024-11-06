module CellTeams.Grid.Model exposing (..)

import Dict exposing (Dict)
import List
import Random
import Fuzz exposing (maybe)
import Dict exposing (values)
import Html.Attributes exposing (coords)


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


getCell : CellCoords -> Grid -> Maybe Cell
getCell c grid =
    Dict.get c grid


getNeighbors : CellCoords -> Grid -> List Cell
getNeighbors coords grid =
    List.filterMap (\c -> getCell c grid) (findNeighboringCoords coords)


isAlive : Cell -> Bool
isAlive cell =
    if cell == Alive then
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
        Alive

    else
        Dead


stepGrid : Grid -> Grid
stepGrid grid = stepSparseGrid grid


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


maybeUpdate : Int -> Maybe Cell -> Maybe Cell
maybeUpdate neighborCount mCell = 
  case mCell of 
    Just Alive -> 
        if neighborCount == 2 || neighborCount == 3 then Just Alive else Just Dead
    _ -> 
        if neighborCount == 3 then Just Alive else Nothing


getBounds :  Grid -> ((Int, Int), (Int, Int))
getBounds grid = 
    let rowsLowToHigh = List.sort (List.map Tuple.first (Dict.keys grid))
        colsLowToHigh = List.sort (List.map Tuple.second (Dict.keys grid))
        
        minRow = max (Maybe.withDefault 0 (List.head rowsLowToHigh)) -5
        maxRow = min (Maybe.withDefault 0 (List.head (List.reverse rowsLowToHigh)) ) 20
        
        minCol =  max (Maybe.withDefault 0 (List.head colsLowToHigh)) -5
        maxCol =  min (Maybe.withDefault 0 (List.head (List.reverse colsLowToHigh))) 20 in
    ((minRow, minCol), (maxRow, maxCol))

getCenter : (Int, Int) -> (Int, Int) -> CellCoords
getCenter (row1, col1) (row2, col2) = (row2 - row1 // 2, col2 - col1 // 2) 

stepSparseGrid : Grid -> Grid
stepSparseGrid grid =
  let (mins, maxes) = Debug.log "bounds" (getBounds grid)
      center =  Debug.log "center" (getCenter mins maxes)
      res = updateCellAndNeighbors mins maxes center grid ([], Dict.empty)
      blah = Debug.log "foo" (List.length (Tuple.first res)) in

    Tuple.second res

withinBounds : (Int, Int) -> (Int, Int) -> CellCoords -> Bool
withinBounds ( minRow, minCol ) (maxRow, maxCol) (row, col) =
    row < maxRow + 1 && col < maxCol + 1 && row >= minRow && row >= minCol


-- Base case:
--   All the neighbors have been updated


updateCellAndNeighbors : ( Int, Int ) -> (Int, Int) -> CellCoords -> Grid -> (List CellCoords, Grid) -> (List CellCoords, Grid)
updateCellAndNeighbors min max coords gridBefore (alreadyUpdated, currentGrid) =
    let neighbors = findNeighboringCoords coords
        notAlreadyUpdated = --Debug.log "neighbors"
          (filterNeighbors min max alreadyUpdated neighbors) in
    if List.length alreadyUpdated < 100 then
        List.foldl
            (\nextCoords acc ->
                updateCellAndNeighbors min max nextCoords gridBefore acc
            )
            (coords :: alreadyUpdated, updateCellInGrid coords gridBefore currentGrid)
            notAlreadyUpdated
    else
        (alreadyUpdated, currentGrid)



filterNeighbors : (Int, Int) -> (Int, Int) -> List CellCoords -> List CellCoords -> List CellCoords
filterNeighbors min max alreadyUpdated neighbors =
    List.filter (\neighbor -> 
            not (List.member neighbor alreadyUpdated) &&
                withinBounds min max neighbor) 
                        neighbors

updateCellInGrid : CellCoords -> Grid -> Grid -> Grid
updateCellInGrid coords gridBefore currentGrid = 
  let neighborCount = aliveNeighbors coords gridBefore 
      mCell = Dict.get coords gridBefore in
  maybeInsert coords (maybeUpdate neighborCount mCell) currentGrid


maybeInsert : comparable -> Maybe b -> Dict comparable b ->  Dict comparable b
maybeInsert k maybeV dict = 
  case maybeV of
      Just val -> Dict.insert k val dict
      Nothing -> dict 