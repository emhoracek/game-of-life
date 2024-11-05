module CellTeams.CellTeams exposing (..)

import Array
import Browser
import Browser.Events
import CellTeams.Grid.Model exposing (Cell, CellState(..), Grid, deadGrid, getCell, stepGrid)
import CellTeams.Grid.Update exposing (GridMsg(..), defaultColumns, defaultRows, makeGrid, updateGrid)
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import List exposing (range)
import Random


cellTeamsMain : Program () Model Msg
cellTeamsMain =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { grid : Grid
    , settings : GameSettings
    , timeInCycle : Int
    , animation : Maybe Int
    , colorway : Colorway
    }


type alias GameSettings =
    { rows : Int, columns : Int }


defaultTiming : Int
defaultTiming =
    100


type alias Colorway =
    { name : String
    , display : Int -> Cell -> String
    }


type Msg
    = NoOp
    | Increment
    | Decrement
    | Stop
    | Go
    | TryNextColorway
    | PickRandomColorway
    | NewColorway Colorway
    | GridMsg GridMsg


init : () -> ( Model, Cmd Msg )
init _ =
    ( { grid = deadGrid defaultRows defaultColumns
      , settings = { rows = 2, columns = 2 }
      , timeInCycle = 0
      , animation = Just defaultTiming
      , colorway = defaultColorway
      }
    , Cmd.map GridMsg makeGrid
    )


incrementModel : Model -> Model
incrementModel model =
    { grid = stepGrid model.grid
    , settings = model.settings
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
    , animation = model.animation
    , colorway = model.colorway
    }


decrementModel : Model -> Model
decrementModel model =
    { grid = model.grid
    , settings = model.settings
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    , colorway = model.colorway
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

        Stop ->
            ( { grid = model.grid, settings = model.settings, timeInCycle = defaultTiming, animation = Nothing, colorway = model.colorway }, Cmd.none )

        Go ->
            ( { grid = model.grid, settings = model.settings, timeInCycle = defaultTiming, animation = Just defaultTiming, colorway = model.colorway }, Cmd.none )

        NewColorway colorway ->
            ( { grid = model.grid, settings = model.settings, timeInCycle = model.timeInCycle, animation = model.animation, colorway = colorway }, Cmd.none )

        TryNextColorway ->
            ( { grid = model.grid, settings = model.settings, timeInCycle = model.timeInCycle, animation = model.animation, colorway = nextColorWay model.colorway }, Cmd.none )

        GridMsg gridMsg ->
            gridMsgToMsg gridMsg model


gridMsgToMsg : GridMsg -> Model -> ( Model, Cmd Msg )
gridMsgToMsg gridMsg model =
    let
        ( grid, cmd ) =
            updateGrid gridMsg model.grid
    in
    ( { grid = grid
      , settings = model.settings
      , timeInCycle = model.timeInCycle
      , animation = model.animation
      , colorway = model.colorway
      }
    , Cmd.map GridMsg cmd
    )


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
        , onClick (GridMsg (ToggleCell ( row, col ) cell))
        ]
        [ text " " ]


showRow : Model -> Int -> List Cell -> Html Msg
showRow model n row =
    tr [] (List.indexedMap (showCell model n) row)


toRows : GameSettings -> Grid -> List (List Cell)
toRows settings grid =
    List.map
        (\r -> List.filterMap (\c -> getCell ( r, c ) grid) (range 0 (settings.columns - 1)))
        (range 0 (settings.rows - 1))


showGrid : Model -> List (Html Msg)
showGrid model =
    List.indexedMap (showRow model) (toRows model.settings model.grid)


view : Model -> Html Msg
view model =
    div []
        [ table [] (showGrid model)
        , button [ onClick Increment ] [ text "Step" ]
        , button [ onClick Go ] [ text "Go" ]
        , button [ onClick Stop ] [ text "Stop" ]
        , button [ onClick (GridMsg (NewGrid (deadGrid defaultRows defaultColumns))) ] [ text "Clear" ]
        , button [ onClick (GridMsg MkNewGrid) ] [ text "Generate!" ]
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
