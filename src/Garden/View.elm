module Garden.View exposing (..)

import Garden.Grid.Model exposing (Cell, CellState(..), Grid, deadGrid)
import Garden.Grid.Update exposing (GridMsg(..), defaultColumns, defaultRows)
import Dict
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List exposing (range)
import Garden.Model exposing (GridId, Msg(..), GameSettings, Model)


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
            ]
        , div [ class "grids" ]
            (Dict.values (Dict.map (\k v -> viewGrid model k v) model.grids))
        ]

