module Garden.View exposing (..)

import Array
import Garden.Display.Model exposing (Display, Plant(..), listDisplay)
import Garden.Grid.Model exposing (CellState(..), Grid, countLiving, deadGrid, getBounds)
import Garden.Grid.Update exposing (GridMsg(..), defaultColumns, defaultRows)
import Garden.Model exposing (GridName(..), Model, Msg(..))
import Html exposing (Html, button, dd, div, dl, dt, table, td, text, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Random
import String exposing (fromInt)


randomColors : Int -> Int -> Random.Generator (List Plant)
randomColors r c =
    Random.list (r * c) (Random.uniform Blue [ Pink, Purple, Yellow ])


generateRandomColors : Int -> Int -> Cmd Msg
generateRandomColors r c =
    Random.generate (\colors -> SetColors (Array.fromList colors)) (randomColors r c)


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


cellClasses : Maybe Plant -> String
cellClasses mPlant =
    case mPlant of
        Nothing ->
            "hide-cell dead"

        Just plant ->
            "alive " ++ plantToText plant


showCell : GridName -> Int -> Int -> Maybe Plant -> Html Msg
showCell gridName row col mPlant =
    let
        cell =
            if mPlant == Nothing then
                Dead

            else
                Alive

        clickHandler =
            if gridName == Nursery then
                [ onClick (GridMsg gridName (ToggleCell ( row, col ) cell)) ]

            else
                []
    in
    td
        (List.append clickHandler [ class "cell" ])
        [ div
            [ class ("cell-content " ++ cellClasses mPlant) ]
            [ text "✽" ]
        ]


showRow : GridName -> Int -> List (Maybe Plant) -> Html Msg
showRow gridName n row =
    tr [] (List.indexedMap (showCell gridName n) row)


showGrid : Grid -> GridName -> Display -> List (Html Msg)
showGrid grid gridName display =
    List.indexedMap (showRow gridName) (listDisplay grid display)


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


viewGrid : Grid -> GridName -> Display -> Html Msg
viewGrid grid gridName display =
    div []
        [ table [] (showGrid grid gridName display)
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
            [ div [ class "nursery" ] [ viewGrid model.nursery Nursery model.nurseryDisplay ]
            , div [ class "garden" ] [ viewGrid model.garden Garden model.gardenDisplay ]
            ]
        ]
