module Garden.Update exposing (..)

import Browser.Events
import Garden.Grid.Model exposing (CellState(..), deadGrid, stepGrid)
import Garden.Grid.Update exposing (GridMsg, defaultColumns, defaultRows, makeGrid, updateGrid)
import Garden.Model exposing (GridName(..), Model, Msg(..))
import Garden.Display.Model exposing (Plant(..))
import Garden.View exposing (generateRandomColors)


defaultTiming : Int
defaultTiming =
    100


init : () -> ( Model, Cmd Msg )
init _ =
    ( { garden = deadGrid defaultRows defaultColumns
      , nursery = deadGrid (defaultRows // 2) (defaultColumns // 2)
      , settings = { rows = defaultRows, columns = defaultColumns }
      , timeInCycle = 0
      , animation = Nothing
      , plants = List.repeat defaultRows (List.repeat defaultColumns Blue)
      }
    , Cmd.batch
        [ Cmd.map (GridMsg Garden) makeGrid
        , generateRandomColors defaultRows defaultColumns
        ]
    )


incrementModel : Model -> Model
incrementModel model =
    { garden = stepGrid model.garden
    , nursery = stepGrid model.nursery
    , settings = model.settings
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
    , animation = model.animation
    , plants = model.plants
    }


decrementModel : Model -> Model
decrementModel model =
    { garden = model.garden
    , nursery = model.nursery
    , settings = model.settings
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    , plants = model.plants
    }


go : Model -> Model
go model =
    { garden = model.garden
    , nursery = model.nursery
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Just defaultTiming
    , plants = model.plants
    }


stop : Model -> Model
stop model =
    { garden = model.garden
    , nursery = model.nursery
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Nothing
    , plants = model.plants
    }


setPlants : Model -> List (List Plant) -> Model
setPlants model plants =
    { garden = model.garden
    , nursery = model.nursery
    , settings = model.settings
    , timeInCycle = model.timeInCycle
    , animation = model.animation
    , plants = plants
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

        SetColors plants ->
            ( setPlants model plants, Cmd.none )

        GridMsg gridName gridMsg ->
            gridMsgToMsg gridName gridMsg model


gridMsgToMsg : GridName -> GridMsg -> Model -> ( Model, Cmd Msg )
gridMsgToMsg gridName gridMsg model =
    let
        ( newGrid, cmd ) =
            updateGrid gridMsg model.garden
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
      , settings = model.settings
      , timeInCycle = model.timeInCycle
      , animation = model.animation
      , plants = model.plants
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
