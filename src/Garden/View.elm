module Garden.View exposing (..)

import Dict
import Garden.Display.Model exposing (Display, Plant(..), listDisplay)
import Garden.Grid.Model exposing (Area, CellState(..), Grid, countLiving, dimensionsOf, getBounds)
import Garden.Grid.Update exposing (GridMsg(..))
import Garden.Model exposing (GridName(..), Model, Msg(..))
import Html exposing (Html, button, dd, div, dl, dt, table, td, text, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import String exposing (fromInt)


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


type alias CellDisplay =
    Int -> Int -> Maybe Plant -> Html Msg


showGardenCell : Area -> CellDisplay
showGardenCell target row col mPlant =
    let
        ( ( r1, c1 ), ( r2, c2 ) ) =
            ( target.topLeft, target.bottomRight )

        inTarget =
            row >= r1 && row <= r2 && col >= c1 && col <= c2

        targetClasses =
            if inTarget then
                "targeted"

            else
                ""
    in
    td
        [ class ("cell " ++ targetClasses) ]
        [ div
            [ class ("cell-content " ++ cellClasses mPlant) ]
            [ text "✽" ]
        ]


showNurseryCell : CellDisplay
showNurseryCell row col mPlant =
    let
        cell =
            if mPlant == Nothing then
                Dead

            else
                Alive
    in
    td
        [ class "cell"
        , onClick (GridMsg Nursery (ToggleCell ( row, col ) cell))
        ]
        [ div
            [ class ("cell-content " ++ cellClasses mPlant) ]
            [ text "✽" ]
        ]


showRow : CellDisplay -> Int -> List (Maybe Plant) -> Html Msg
showRow showCell n row =
    tr [] (List.indexedMap (showCell n) row)


showGrid : Grid -> CellDisplay -> Display -> List (Html Msg)
showGrid grid showCell display =
    List.indexedMap (showRow showCell) (listDisplay grid display)


showGridData : Grid -> Html Msg
showGridData grid =
    let
        area =
            getBounds grid

        ( minY, minX ) =
            area.topLeft

        ( maxY, maxX ) =
            area.bottomRight

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


viewGarden : Grid -> Display -> Area -> Html Msg
viewGarden grid display target =
    div []
        [ table [] (showGrid grid (showGardenCell target) display)
        , div [] [ showGridData grid ]
        , div [ class "gridcommands" ]
            [ button
                []
                [ text "⭠" ]
            , button
                []
                [ text "⭡" ]
            , button
                []
                [ text "⭣" ]
            , button
                [ onClick MoveRight ]
                [ text "⭢" ]
            ]
        ]


viewNursery : Grid -> Display -> Html Msg
viewNursery grid display =
    div []
        [ table [] (showGrid grid showNurseryCell display)
        , div [] [ showGridData grid ]
        , div [ class "gridcommands" ]
            [ button
                [ onClick
                    (GridMsg Nursery (NewGrid Dict.empty))
                ]
                [ text "Clear" ]
            , button [ onClick (GridMsg Nursery (MkNewGrid (dimensionsOf display.area))) ] [ text "Generate!" ]
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
            , button [ onClick AddNursery ] [ text "Add nursery plants" ]
            ]
        , div [ class "grids" ]
            [ div [ class "nursery" ] [ viewNursery model.nursery model.nurseryDisplay ]
            , div [ class "garden" ] [ viewGarden model.garden model.gardenDisplay model.nurseryTarget ]
            ]
        ]
