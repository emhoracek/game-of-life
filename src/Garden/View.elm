module Garden.View exposing (..)

import Dict
import Garden.Grid.Model exposing (Cell, CellState(..), Grid, countLiving, deadGrid, getBounds)
import Garden.Grid.Update exposing (GridMsg(..), defaultColumns, defaultRows)
import Garden.Model exposing (DisplayGrid, GameSettings, GridId, Model, Msg(..), Plant(..))
import Html exposing (Html, button, dd, div, dl, dt, table, td, text, tr)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import List exposing (range)
import Random
import String exposing (fromInt)


toPlants : Int -> Grid -> Int -> List (Maybe Plant)
toPlants cols grid row =
    let
        cell col =
            Dict.get ( row, col ) grid
    in
    List.map (\col -> cellToPlant (cell col)) (range 0 (cols - 1))


cellToPlant : Maybe CellState -> Maybe Plant
cellToPlant mCell =
    case mCell of
        Just Dead ->
            Nothing

        Just Alive ->
            Just Blue

        _ ->
            Nothing


toDisplayGrid : GameSettings -> Grid -> DisplayGrid
toDisplayGrid settings grid =
    List.map
        (\row -> toPlants settings.columns grid row)
        (range 0 (settings.rows - 1))


randomColors : Int -> Int -> Random.Generator (List (List Plant))
randomColors r c =
    Random.list r (Random.list c (Random.uniform Blue [ Pink, Purple, Yellow ]))


generateRandomColors : Int -> Int -> Cmd Msg
generateRandomColors r c =
    Random.generate (\colors -> SetColors colors) (randomColors r c)


plantToText : Plant -> String
plantToText plant =
    case plant of
        Blue ->
            "blue-plant"

        Pink ->
            "pink-plant"

        Purple ->
            "purple-plant"

        Yellow ->
            "yellow-plant"


cellToText : Cell -> String
cellToText cell =
    if cell == Alive then
        "alive"

    else
        "dead"


toVisibility : CellState -> Plant -> String
toVisibility cell plant =
    if cell == Alive then
        plantToText plant

    else
        "hide-cell"


showCell : GridId -> Int -> Int -> ( Cell, Plant ) -> Html Msg
showCell gridId row col ( cell, plant ) =
    td
        [ class "cell"
        , onClick (GridMsg gridId (ToggleCell ( row, col ) cell))
        ]
        [ div
            [ classList
                [ ( "cell-content", True )
                , ( toVisibility cell plant, True )
                , ( cellToText cell, True )
                ]
            ]
            [ text "✽" ]
        ]


showRow : GridId -> Int -> List ( Cell, Plant ) -> Html Msg
showRow gridId n row =
    tr [] (List.indexedMap (showCell gridId n) row)


toColumns : Grid -> Int -> List Plant -> List ( Cell, Plant )
toColumns grid row plants =
    let
        cell col plant =
            ( Maybe.withDefault Dead (Dict.get ( row, col ) grid), plant )
    in
    List.indexedMap cell plants


toRows : Grid -> List (List Plant) -> List (List ( Cell, Plant ))
toRows grid plants =
    List.indexedMap
        (toColumns grid)
        plants


showGrid : Model -> GridId -> Grid -> List (Html Msg)
showGrid model gridId grid =
    List.indexedMap (showRow gridId) (toRows grid model.plants)


showGridData : Grid -> Html Msg
showGridData grid =
    let
        ( ( minY, minX ), ( maxY, maxX ) ) =
            getBounds grid

        boundsStrings =
            [ "("
            , fromInt minX
            , ", "
            , fromInt minY
            , ") to ("
            , fromInt maxX
            , ", "
            , fromInt maxY
            , ")"
            ]

        liveCells =
            countLiving grid
    in
    dl [ class "grid-data" ]
        [ div [ class "definition" ]
            [ dt [] [ text "Live cells" ]
            , dd [] [ text (fromInt liveCells) ]
            ]
        , div [ class "definition" ]
            [ dt [] [ text "Live area" ]
            , dd [] [ text (String.join "" boundsStrings) ]
            ]
        ]


viewGrid : Model -> GridId -> Grid -> Html Msg
viewGrid model gridId grid =
    div []
        [ table [] (showGrid model gridId grid)
        , div [] [ showGridData grid ]
        , div [ class "gridcommands" ]
            [ button [ onClick (GridMsg gridId (NewGrid (deadGrid defaultRows defaultColumns))) ] [ text "Clear" ]
            , button [ onClick (GridMsg gridId MkNewGrid) ] [ text "Generate!" ]
            ]
        ]


stopGoButton : Model -> Html Msg
stopGoButton model =
    case model.animation of
        Nothing ->
            button [ onClick Go ] [ text "Go" ]

        _ ->
            button [ onClick Stop ] [ text "Pause" ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "globalcommands" ]
            [ button [ onClick Increment ] [ text "Step" ]
            , stopGoButton model
            ]
        , div [ class "grids" ]
            (Dict.values (Dict.map (\k v -> viewGrid model k v) model.grids))
        ]
