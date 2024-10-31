module TakeTwo exposing (..)

import Array exposing (Array, fromList, toList)
import Browser
import Browser.Events
import Debug
import Dict exposing (Dict)
import Html exposing (Html, button, div, li, table, td, text, tr, ul)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import List exposing (range)
import Maybe
import Random
import TakeOne exposing (Cell(..), columns, rows)
import Test.Html.Query exposing (index)
import Time



--takeTwoMain : Program () Model Msg


takeTwoMain =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type CellState
    = Alive
    | Dead


type alias CellCoords =
    ( Int, Int )


type alias Cell =
    { coords : CellCoords
    , state : CellState
    }


type alias Grid =
    { cells : Dict CellCoords Cell
    , rows : Int
    , columns : Int
    }


type alias Model =
    { grid : Grid
    , liveliness : Int
    }


smallGrid : Grid
smallGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { coords = ( 0, 0 )
                , state = Alive
                }
              )
            , ( ( 0, 1 )
              , { coords = ( 0, 1 )
                , state = Alive
                }
              )
            , ( ( 1, 0 )
              , { coords = ( 1, 0 )
                , state = Alive
                }
              )
            , ( ( 1, 1 )
              , { coords = ( 1, 1 )
                , state = Alive
                }
              )
            ]
    , rows = 2
    , columns = 2
    }


toCenter : ( Int, Int ) -> CellCoords
toCenter ( rows, cols ) =
    ( floor (toFloat rows / 2), floor (toFloat cols / 2) )


createOriginCell : Int -> Int -> Cell
createOriginCell rows cols =
    { coords = toCenter ( rows, cols )
    , state = Alive
    }


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
        (Dict.insert ( a, b ) (Cell ( a, b ) state) cells)
        (List.filter (\coords -> Dict.get coords cells == Nothing) (findNeighboringCoords ( a, b )))


createGrid : Int -> Int -> CellState -> Grid
createGrid r c state =
    { cells = createCellAndNeighbors ( r, c ) (toCenter ( r, c )) state Dict.empty
    , rows = r
    , columns = c
    }


cellToInt : Cell -> Int
cellToInt cell =
    case cell.state of
        Alive ->
            1

        Dead ->
            0


defaultRows =
    20


defaultColumns =
    20


defaultTiming =
    100


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
            ( coords, Cell coords state )
        )
        cells


usuallyAlive ( rows, columns ) =
    Random.map
        (\l -> Grid (Dict.fromList (listToIndexedList columns l)) rows columns)
        (Random.list (rows * columns) usuallyAliveCell)


makeGrid : Cmd Msg
makeGrid =
    Random.generate NewGrid (usuallyAlive ( defaultRows, defaultColumns ))


init : () -> ( Model, Cmd Msg )
init _ =
    ( { grid = smallGrid
      , liveliness = 0
      }
    , makeGrid
    )


type Msg
    = Increment
    | NewGrid Grid
    | MkNewGrid
    | Decrement


getCell : CellCoords -> Grid -> Maybe Cell
getCell c grid =
    Dict.get c grid.cells


getNeighbors : CellCoords -> Grid -> List (Maybe Cell)
getNeighbors coords grid =
    List.map (\c -> getCell c grid) (findNeighboringCoords coords)


isAlive : Maybe Cell -> Bool
isAlive cell =
    if Maybe.map .state cell == Just Alive then
        True

    else
        False


aliveNeighbors : CellCoords -> Grid -> Int
aliveNeighbors coords grid =
    List.length (List.filter isAlive (getNeighbors coords grid))


willBeAlive : CellCoords -> Grid -> Bool
willBeAlive c grid =
    if isAlive (getCell c grid) then
        aliveNeighbors c grid
            == 2
            || aliveNeighbors c grid
            == 3

    else
        aliveNeighbors c grid == 3


updateAlive : CellCoords -> Grid -> Cell
updateAlive loc grid =
    if
        aliveNeighbors loc grid
            == 2
            || aliveNeighbors loc grid
            == 3
    then
        Cell loc Alive

    else
        Cell loc Dead


updateDead : CellCoords -> Grid -> Cell
updateDead loc grid =
    if aliveNeighbors loc grid == 3 then
        Cell loc Alive

    else
        Cell loc Dead


updateCell : Cell -> CellCoords -> Grid -> Cell
updateCell cell loc grid =
    if cell.state == Alive then
        updateAlive loc grid

    else
        updateDead loc grid


updateRows : Grid -> Grid
updateRows grid =
    { cells = Dict.foldr (\k c acc -> Dict.insert k (updateCell c c.coords grid) acc) grid.cells grid.cells
    , rows = grid.rows
    , columns = grid.columns
    }


incrementModel : Model -> Model
incrementModel model =
    { grid = updateRows model.grid
    , liveliness = defaultTiming
    }


decrementModel : Model -> Model
decrementModel model =
    { grid = model.grid
    , liveliness = model.liveliness - 1
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Decrement ->
            ( decrementModel model, Cmd.none )

        Increment ->
            ( incrementModel model, Cmd.none )

        MkNewGrid ->
            ( model, makeGrid )

        NewGrid newGrid ->
            ( { grid = newGrid, liveliness = model.liveliness }, Cmd.none )


showCell2 color =
    td
        [ style "background" color
        , style "width" "1em"
        , style "height" "1em"
        ]
        [ text " " ]


showCell n cell =
    let
        min =
            20

        max =
            100

        p =
            min + round ((toFloat n / 100) * (max - min))
    in
    if cell.state == Alive then
        showCell2 ("hsl(150 " ++ Debug.toString p ++ "% " ++ Debug.toString p ++ "%)")

    else
        showCell2 "#333333"


showRow n row =
    tr [] (List.map (\c -> showCell n c) row)


showGrid n grid =
    List.map (showRow n) (toRows grid)


toRows : Grid -> List (List Cell)
toRows grid =
    List.map (\r -> List.filterMap (\c -> getCell ( r, c ) grid) (List.range 0 (grid.columns - 1)))
        (List.range 0 (grid.rows - 1))


view : Model -> Html Msg
view model =
    div []
        [ table [] (showGrid model.liveliness model.grid)
        , button [ onClick Increment ] [ text "GO!" ]
        , button [ onClick MkNewGrid ] [ text "Generate!" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onAnimationFrame
        (\p ->
            if model.liveliness == 0 then
                Increment

            else
                Decrement
        )
