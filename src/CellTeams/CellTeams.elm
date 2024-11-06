module CellTeams.CellTeams exposing (..)

import Array
import Browser
import Browser.Events
import CellTeams.Grid.Model exposing (Cell, CellState(..), Grid, deadGrid, stepGrid)
import CellTeams.Grid.Update exposing (GridMsg(..), defaultColumns, defaultRows, makeGrid, updateGrid)
import Dict exposing (Dict)
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (class)
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
    { grids : Dict GridId Grid
    , settings : GameSettings
    , timeInCycle : Int
    , animation : Maybe Int
    , colorway : Colorway
    }


type alias GridId =
    String


type alias GameSettings =
    { rows : Int, columns : Int }


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
    | GridMsg GridId GridMsg


defaultTiming : Int
defaultTiming =
    100


init : () -> ( Model, Cmd Msg )
init _ =
    ( { grids = Dict.fromList [ ( "0", deadGrid defaultRows defaultColumns ), ( "1", deadGrid defaultRows defaultColumns ) ]
      , settings = { rows = defaultRows, columns = defaultColumns }
      , timeInCycle = 0
      , animation = Nothing
      , colorway = defaultColorway
      }
    , Cmd.batch [ Cmd.map (GridMsg "0") makeGrid, Cmd.map (GridMsg "1") makeGrid ]
    )


incrementModel : Model -> Model
incrementModel model =
    { grids = Dict.map (\_ -> stepGrid) model.grids
    , settings = model.settings
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
    , animation = model.animation
    , colorway = model.colorway
    }


decrementModel : Model -> Model
decrementModel model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    , colorway = model.colorway
    }


tryNextColorWay : Model -> Model
tryNextColorWay model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = model.timeInCycle
    , animation = model.animation
    , colorway = nextColorWay model.colorway
    }


newColorway : Colorway -> Model -> Model
newColorway colorway model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = model.timeInCycle
    , animation = model.animation
    , colorway = colorway
    }


go : Model -> Model
go model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Just defaultTiming
    , colorway = model.colorway
    }


stop : Model -> Model
stop model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Nothing
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
            ( stop model, Cmd.none )

        Go ->
            ( go model, Cmd.none )

        NewColorway colorway ->
            ( newColorway colorway model, Cmd.none )

        TryNextColorway ->
            ( tryNextColorWay model, Cmd.none )

        GridMsg gridId gridMsg ->
            gridMsgToMsg gridId gridMsg model


gridMsgToMsg : GridId -> GridMsg -> Model -> ( Model, Cmd Msg )
gridMsgToMsg gridId gridMsg model =
    let
        grid =
            Maybe.withDefault (deadGrid defaultRows defaultColumns) (Dict.get gridId model.grids)

        ( newGrid, cmd ) =
            updateGrid gridMsg grid
    in
    ( { grids = Dict.insert gridId newGrid model.grids
      , settings = model.settings
      , timeInCycle = model.timeInCycle
      , animation = model.animation
      , colorway = model.colorway
      }
    , Cmd.map (GridMsg gridId) cmd
    )


greenAndGrey : Colorway
greenAndGrey =
    Colorway "greenAndGray"
        (\_ cell ->
            if cell == Alive then
                "green"

            else
                "#CCC"
        )


redAndBlack : Colorway
redAndBlack =
    Colorway "redAndBlack"
        (\_ cell ->
            if cell == Alive then
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
            if cell == Alive then
                "hsl(150 " ++ String.fromInt p ++ "% " ++ String.fromInt p ++ "%)"

            else
                "#333333"
        )


defaultColorway : Colorway
defaultColorway =
    redAndBlack


otherColorways : List Colorway
otherColorways =
    [ glowyPop, greenAndGrey ]


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


toText : CellState -> String
toText cell = 
    if cell == Alive then "✽" else " "

toClass : CellState -> String
toClass cell = 
    if cell == Alive then "alive cell" else "dead cell"


toVisibility : CellState -> String
toVisibility cell = 
    if cell == Alive then "cell-content show-cell" else "cell-content hide-cell"

showCell : GridId -> Int -> Int -> Cell -> Html Msg
showCell gridId row col cell =
    td
        [ class (toClass cell)
        , onClick (GridMsg gridId (ToggleCell ( row, col ) cell))
        ]
        [ div [class (toVisibility cell) ] [text "✽"] ]


showRow : GridId -> Int -> List Cell -> Html Msg
showRow gridId n row =
    tr [] (List.indexedMap (showCell gridId n) row)


toColumns : Int -> Grid -> Int -> List Cell
toColumns cols grid row =
    let
        cell col =
            Maybe.withDefault Dead (Dict.get ( row, col ) grid)
    in
    List.map (\col -> cell col) (range 0 (cols - 1))


toRows : GameSettings -> Grid -> List (List Cell)
toRows settings grid =
    List.map
        (toColumns settings.columns grid)
        (range 0 (settings.rows - 1))


showGrid : Model -> GridId -> Grid -> List (Html Msg)
showGrid model gridId grid =
    List.indexedMap (showRow gridId) (toRows model.settings grid)


viewGrid : Model -> GridId -> Grid -> Html Msg
viewGrid model gridId grid =
    div []
        [ table [] (showGrid model gridId grid)
        , div [ class "gridcommands" ]
            [ button [ onClick (GridMsg gridId (NewGrid (deadGrid defaultRows defaultColumns))) ] [ text "Clear" ]
            , button [ onClick (GridMsg gridId MkNewGrid) ] [ text "Generate!" ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "globalcommands" ]
            [ button [ onClick Increment ] [ text "Step" ]
            , button [ onClick Go ] [ text "Go" ]
            , button [ onClick Stop ] [ text "Stop" ]
            , button [ onClick TryNextColorway ] [ text "Change colors!" ]
            ]
        , div [ class "grids" ]
            (Dict.values (Dict.map (\k v -> viewGrid model k v) model.grids))
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.animation /= Nothing then
        Browser.Events.onAnimationFrame
            (\_ ->
                if model.timeInCycle == 0 then
                    Increment

                else
                    Decrement
            )

    else
        Sub.none
