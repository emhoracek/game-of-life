module Garden.Update exposing (..)

import Array exposing (Array)
import Browser.Events
import Dict
import Garden.Display.Model exposing (Plant(..), centerAt, initGardenDisplay, initNurseryDisplay, randomColors)
import Garden.Grid.Model exposing (CellState(..), addSubGrid, centerOf, stepGrid)
import Garden.Grid.Update exposing (GridMsg, defaultColumns, defaultRows, updateGrid)
import Garden.Model exposing (GridName(..), Model, Msg(..), moveVisibleGrid)
import Random


defaultTiming : Int
defaultTiming =
    100


init : () -> ( Model, Cmd Msg )
init _ =
    ( { garden = Dict.empty
      , nursery = Dict.empty
      , gardenDisplay = initGardenDisplay
      , nurseryDisplay = initNurseryDisplay
      , nurseryTarget = centerAt initNurseryDisplay (centerOf initGardenDisplay.area)
      , timeInCycle = 0
      , animation = Nothing
      }
    , Cmd.batch
        [ generateRandomColors defaultRows defaultColumns ]
    )


incrementModel : Model -> Model
incrementModel model =
    { garden = stepGrid model.garden
    , nursery = stepGrid model.nursery
    , gardenDisplay = model.gardenDisplay
    , nurseryDisplay = model.nurseryDisplay
    , nurseryTarget = model.nurseryTarget
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
    , animation = model.animation
    }


decrementModel : Model -> Model
decrementModel model =
    { garden = model.garden
    , nursery = model.nursery
    , gardenDisplay = model.gardenDisplay
    , nurseryDisplay = model.nurseryDisplay
    , nurseryTarget = model.nurseryTarget
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    }


go : Model -> Model
go model =
    { garden = model.garden
    , nursery = model.nursery
    , gardenDisplay = model.gardenDisplay
    , nurseryDisplay = model.nurseryDisplay
    , nurseryTarget = model.nurseryTarget
    , timeInCycle = defaultTiming
    , animation = Just defaultTiming
    }


stop : Model -> Model
stop model =
    { garden = model.garden
    , nursery = model.nursery
    , gardenDisplay = model.gardenDisplay
    , nurseryDisplay = model.nurseryDisplay
    , nurseryTarget = model.nurseryTarget
    , timeInCycle = defaultTiming
    , animation = Nothing
    }


addNursery : Model -> Model
addNursery model =
    let
        newGrid =
            moveVisibleGrid model.nursery model.nurseryDisplay model.gardenDisplay
    in
    { garden = addSubGrid model.garden newGrid
    , nursery = model.nursery
    , gardenDisplay = model.gardenDisplay
    , nurseryDisplay = model.nurseryDisplay
    , nurseryTarget = model.nurseryTarget
    , timeInCycle = model.timeInCycle
    , animation = model.animation
    }


setPlants : Model -> Array Plant -> Model
setPlants model plants =
    { garden = model.garden
    , nursery = model.nursery
    , gardenDisplay =
        { area = model.gardenDisplay.area
        , plants = plants
        }
    , nurseryDisplay =
        { area = model.nurseryDisplay.area
        , plants = plants
        }
    , nurseryTarget = model.nurseryTarget
    , timeInCycle = model.timeInCycle
    , animation = model.animation
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

        Stop ->
            ( stop model, Cmd.none )

        Go ->
            ( go model, Cmd.none )

        AddNursery ->
            ( addNursery model, Cmd.none )

        SetColors plants ->
            ( setPlants model plants, Cmd.none )

        GridMsg gridName gridMsg ->
            gridMsgToMsg gridName gridMsg model


gridMsgToMsg : GridName -> GridMsg -> Model -> ( Model, Cmd Msg )
gridMsgToMsg gridName gridMsg model =
    let
        ( newGrid, cmd ) =
            if gridName == Garden then
                updateGrid gridMsg model.garden

            else
                updateGrid gridMsg model.nursery
    in
    ( { garden =
            if gridName == Garden then
                newGrid

            else
                model.garden
      , nursery =
            if gridName == Nursery then
                newGrid

            else
                model.nursery
      , gardenDisplay = model.gardenDisplay
      , nurseryDisplay = model.nurseryDisplay
      , nurseryTarget = model.nurseryTarget
      , timeInCycle = model.timeInCycle
      , animation = model.animation
      }
    , Cmd.map (GridMsg gridName) cmd
    )


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


generateRandomColors : Int -> Int -> Cmd Msg
generateRandomColors r c =
    Random.generate (\colors -> SetColors (Array.fromList colors)) (randomColors r c)
