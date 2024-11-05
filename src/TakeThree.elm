module TakeThree exposing (..)

import Array
import Browser
import Browser.Events
import Dict exposing (Dict)
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import List exposing (range)
import Random
import TakeOne exposing (Cell(..), columns, rows)



takeThreeMain : Program () Model Msg
takeThreeMain =
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
    { state : CellState
    }


type alias Grid =
    { cells : Dict CellCoords Cell
    , rows : Int
    , columns : Int
    }


type alias Colorway =
    { name : String
    , display : Int -> Cell -> String
    }


type alias Model =
    { grid : Grid
    , timeInCycle : Int
    , animation : Maybe Int
    , colorway : Colorway
    }


type Msg
    = NoOp
    | Increment
    | Decrement
    | NewGrid Grid
    | MkNewGrid
    | Stop
    | Go
    | TryNextColorway
    | PickRandomColorway
    | NewColorway Colorway
    | ToggleCell CellCoords Cell


smallGrid : Grid
smallGrid =
    { cells =
        Dict.fromList
            [ ( ( 0, 0 )
              , { state = Alive
                }
              )
            , ( ( 0, 1 )
              , { state = Alive
                }
              )
            , ( ( 1, 0 )
              , { state = Alive
                }
              )
            , ( ( 1, 1 )
              , { state = Alive
                }
              )
            ]
    , rows = 2
    , columns = 2
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


defaultRows : Int
defaultRows =
    20


defaultColumns : Int
defaultColumns =
    20


defaultTiming : Int
defaultTiming =
    100


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
      , colorway = defaultColorway
      }
    , makeGrid
    )


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


updateRows : Grid -> Grid
updateRows grid =
    { cells = Dict.foldr (\k c acc -> Dict.insert k (updateCell k c grid) acc) grid.cells grid.cells
    , rows = grid.rows
    , columns = grid.columns
    }


deadGrid : Grid
deadGrid =
    createGrid defaultRows defaultColumns Dead


incrementModel : Model -> Model
incrementModel model =
    { grid = updateRows model.grid
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
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


toggleState : CellState -> CellState
toggleState state =
    if state == Alive then
        Dead

    else
        Alive


toggleCell : CellCoords -> Cell -> Grid -> Grid
toggleCell coords cell grid =
    { cells = Dict.insert coords (Cell (toggleState cell.state)) grid.cells
    , rows = grid.rows
    , columns = grid.columns
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Decrement ->
            ( decrementModel model, Cmd.none )

        Increment ->
            ( incrementModel model, Cmd.none )

        PickRandomColorway ->
            ( model, pickRandomColorway )

        MkNewGrid ->
            ( model, makeGrid )

        NewGrid newGrid ->
            ( { grid = newGrid, timeInCycle = model.timeInCycle, animation = model.animation, colorway = model.colorway }, Cmd.none )

        Stop ->
            ( { grid = model.grid, timeInCycle = defaultTiming, animation = Nothing, colorway = model.colorway }, Cmd.none )

        Go ->
            ( { grid = model.grid, timeInCycle = defaultTiming, animation = Just defaultTiming, colorway = model.colorway }, Cmd.none )

        NewColorway colorway ->
            ( { grid = model.grid, timeInCycle = model.timeInCycle, animation = model.animation, colorway = colorway }, Cmd.none )

        TryNextColorway ->
            ( { grid = model.grid, timeInCycle = model.timeInCycle, animation = model.animation, colorway = nextColorWay model.colorway }, Cmd.none )

        ToggleCell coords cell ->
            ( { grid = toggleCell coords cell model.grid, timeInCycle = model.timeInCycle, animation = model.animation, colorway = model.colorway }, Cmd.none )


greenAndGrey : Colorway
greenAndGrey =
    Colorway "greenAndGray"
        (\_ cell ->
            if cell.state == Alive then
                "green"

            else
                "#CCC"
        )


redAndBlack : Colorway
redAndBlack =
    Colorway "redAndBlack"
        (\_ cell ->
            if cell.state == Alive then
                "red"

            else
                "black"
        )


glowyPop : Colorway
glowyPop =
    Colorway "glowyPop"
        (\time cell ->
            let
                min =
                    25

                max =
                    75

                p =
                    min + round ((toFloat time / toFloat defaultTiming) * (max - min))
            in
            if cell.state == Alive then
                "hsl(150 " ++ String.fromInt p ++ "% " ++ String.fromInt p ++ "%)"

            else
                "#333333"
        )




defaultColorway : Colorway
defaultColorway =
    glowyPop


otherColorways : List Colorway
otherColorways =
    [ redAndBlack, greenAndGrey ]


allColorways : List Colorway
allColorways =
    defaultColorway :: otherColorways


getColorwayIndex : String -> Maybe Int
getColorwayIndex name =
    List.head
        (List.filterMap (\a -> a)
            (List.indexedMap
                (\i c ->
                    if c.name == name then
                        Just i

                    else
                        Nothing
                )
                allColorways
            )
        )


nextColorWay : Colorway -> Colorway
nextColorWay currentColorway =
    let
        maybeIndex =
            getColorwayIndex currentColorway.name

        maybeColorway =
            Maybe.andThen (\i -> Array.get (i + 1) (Array.fromList allColorways)) maybeIndex
    in
    Maybe.withDefault defaultColorway maybeColorway


pickRandomColorway : Cmd Msg
pickRandomColorway =
    Random.generate NewColorway (Random.uniform defaultColorway otherColorways)


showCell : Model -> Int -> Int -> Cell -> Html Msg
showCell model row col cell =
    td
        [ style "background" (model.colorway.display model.timeInCycle cell)
        , style "width" "1em"
        , style "height" "1em"
        , onClick (ToggleCell (row, col) cell)
        ]
        [ text " " ]


showRow : Model -> Int -> List Cell -> Html Msg
showRow model n row =
    tr [] (List.indexedMap (showCell model n) row)


toRows : Grid -> List (List Cell)
toRows grid =
    List.map
        (\r -> List.filterMap (\c -> getCell ( r, c ) grid) (range 0 (grid.columns - 1)))
        (range 0 (grid.rows - 1))


showGrid : Model -> List (Html Msg)
showGrid model =
    List.indexedMap (showRow model) (toRows model.grid)


view : Model -> Html Msg
view model =
    div []
        [ table [] (showGrid model)
        , button [ onClick Increment ] [ text "Step" ]
        , button [ onClick Go ] [ text "Go" ]
        , button [ onClick Stop ] [ text "Stop" ]
        , button [ onClick (NewGrid deadGrid) ] [ text "Clear" ]
        , button [ onClick MkNewGrid ] [ text "Generate!" ]
        , button [ onClick TryNextColorway ] [ text "Change colors!" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onAnimationFrame
        (\_ ->
            if model.animation /= Nothing then
                if model.timeInCycle == 0 then
                    Increment

                else
                    Decrement

            else
                NoOp
        )
