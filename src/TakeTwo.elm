module TakeTwo exposing (..)

import Browser
import Browser.Events
import Debug
import Dict exposing (Dict)
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import List exposing (range)
import Random
import TakeOne exposing (Cell(..), columns, rows)



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

type alias Colorway = Int -> Cell -> String

type alias Model =
    { grid : Grid
    , timeInCycle : Int
    , animation: Maybe Int
    , colorway: Colorway
    }



type Msg
    = NoOp
    | Increment
    | Decrement
    | NewGrid Grid
    | MkNewGrid
    | Stop
    | Go
    | PickRandomColorway
    | NewColorway Colorway


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
      , timeInCycle = 0
      , animation = Just defaultTiming
      , colorway = glowyPop
      }
    , makeGrid
    )

getCell : CellCoords -> Grid -> Maybe Cell
getCell c grid =
    Dict.get c grid.cells


getNeighbors : Cell -> Grid -> List Cell
getNeighbors cell grid =
    List.filterMap (\c -> getCell c grid) (findNeighboringCoords cell.coords)


isAlive : Cell -> Bool
isAlive cell =
    if cell.state == Alive then
        True

    else
        False


aliveNeighbors : Cell -> Grid -> Int
aliveNeighbors cell grid =
    List.length (List.filter isAlive (getNeighbors cell grid))


willBeAlive : Cell -> Int -> Bool
willBeAlive c liveNeighbors =
    if isAlive c then
        liveNeighbors
            == 2
            || liveNeighbors
            == 3

    else
        liveNeighbors == 3


updateCell : Cell -> Grid -> Cell
updateCell cell grid =
    if willBeAlive cell (aliveNeighbors cell grid) then
      Cell cell.coords Alive

    else
      Cell cell.coords Dead


updateRows : Grid -> Grid
updateRows grid =
    { cells = Dict.foldr (\k c acc -> Dict.insert k (updateCell c grid) acc) grid.cells grid.cells
    , rows = grid.rows
    , columns = grid.columns
    }


incrementModel : Model -> Model
incrementModel model =
    { grid = updateRows model.grid
    , timeInCycle = defaultTiming
    , animation = model.animation
    , colorway = model.colorway
    }


decrementModel : Model -> Model
decrementModel model =
    { grid = model.grid
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    , colorway = model.colorway
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp -> (model, Cmd.none )
        Decrement ->
            ( decrementModel model, Cmd.none )

        Increment ->
            ( incrementModel model, Cmd.none )

        PickRandomColorway ->
            ( model, pickRandomColorway )

        MkNewGrid ->
            ( model, makeGrid )

        NewGrid newGrid ->
            ( { grid = newGrid, timeInCycle = model.timeInCycle, animation = model.animation, colorway = model.colorway}, Cmd.none )

        Stop ->
            ( { grid = model.grid, timeInCycle = model.timeInCycle, animation = Nothing , colorway = model.colorway}, Cmd.none )
        
        Go ->
            ( { grid = model.grid, timeInCycle = model.timeInCycle, animation = Just defaultTiming, colorway = model.colorway }, Cmd.none )

        NewColorway colorway ->
            ( { grid = model.grid, timeInCycle = model.timeInCycle, animation = model.animation, colorway = colorway }, Cmd.none )



redAndBlack : Int -> Cell -> String
redAndBlack n cell =
    if cell.state == Alive then
        "red"

    else
        "black"

glowyPop : Int -> Cell -> String
glowyPop n cell =
    let
        min =
            25

        max =
            75

        p =
            min + round ((toFloat n / 100) * (max - min))
    in
    if cell.state == Alive then
        "hsl(150 " ++ Debug.toString p ++ "% " ++ Debug.toString p ++ "%)"

    else
        "#333333"

colorways = [glowyPop, redAndBlack]

pickRandomColorway : Cmd Msg
pickRandomColorway =
    Random.generate NewColorway (Random.uniform (glowyPop) [redAndBlack])

showCell model cell =
    td
        [ style "background" (model.colorway model.timeInCycle cell)
        , style "width" "1em"
        , style "height" "1em"
        ]
        [ text " " ]

showRow model row =
    tr [] (List.map (\c -> showCell model c) row)

toRows : Grid -> List (List Cell)
toRows grid =
    List.map 
        (\r -> List.filterMap (\c -> getCell ( r, c ) grid) (range 0 (grid.columns - 1)))
        (range 0 (grid.rows - 1))

showGrid model =
    List.map (showRow model) (toRows model.grid)

view : Model -> Html Msg
view model =
    div []
        [ table [] (showGrid model)
        , button [ onClick Increment ] [ text "Step" ]
        , button [ onClick Go ] [ text "Go" ]
        , button [ onClick Stop ] [ text "Stop" ]
        , button [ onClick MkNewGrid ] [ text "Generate!" ]
        , button [ onClick PickRandomColorway ] [ text "Change colors!" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onAnimationFrame
        (\p ->
          if model.animation /= Nothing then
            if model.timeInCycle == 0 then
                Increment
            else
                Decrement
          else NoOp
        )
