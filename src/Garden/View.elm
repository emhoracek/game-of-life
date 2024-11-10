module Garden.View exposing (..)

import Dict
import Garden.Grid.Model exposing (Cell, CellState(..), Grid, countLiving, deadGrid, getBounds)
import Garden.Grid.Update exposing (GridMsg(..), defaultColumns, defaultRows)
import Garden.Model exposing (GameSettings, GridName(..), Model, Msg(..), Plant(..))
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


showCell : Int -> Int -> ( Cell, Plant ) -> Html Msg
showCell row col ( cell, plant ) =
    td
        [ class "cell"
        , onClick (GridMsg Nursery (ToggleCell ( row, col ) cell))
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


showRow : Int -> List ( Cell, Plant ) -> Html Msg
showRow n row =
    tr [] (List.indexedMap (showCell n) row)


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


showGrid : Model -> Grid -> List (Html Msg)
showGrid model grid =
    List.indexedMap showRow (toRows grid model.plants)


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


viewGrid : Model -> GridName -> Grid -> Html Msg
viewGrid model gridName grid =
    div []
        [ table [] (showGrid model grid)
        , div [] [ showGridData grid ]
        , div [ class "gridcommands" ]
            [ button
                [ onClick
                    (GridMsg gridName (NewGrid (deadGrid defaultRows defaultColumns)))
                ]
                [ text "Clear" ]
            , button [ onClick (GridMsg gridName MkNewGrid) ] [ text "Generate!" ]
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
            [ div [ class "nursery" ] [ viewGrid model Nursery model.nursery ]
            , div [ class "garden" ] [ viewGrid model Garden model.garden ]
            ]
        ]
