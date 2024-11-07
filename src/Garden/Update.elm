module Garden.Update exposing (..)

import Browser.Events
import Dict
import Garden.Grid.Model exposing (CellState(..), deadGrid, stepGrid)
import Garden.Grid.Update exposing (GridMsg, defaultColumns, defaultRows, makeGrid, updateGrid)
import Garden.Model exposing (GridId, Model, Msg(..), Plant(..))
import Garden.View exposing (generateRandomColors)


defaultTiming : Int
defaultTiming =
    100


init : () -> ( Model, Cmd Msg )
init _ =
    ( { grids = Dict.fromList [ ( "0", deadGrid defaultRows defaultColumns ), ( "1", deadGrid defaultRows defaultColumns ) ]
      , settings = { rows = defaultRows, columns = defaultColumns }
      , timeInCycle = 0
      , animation = Nothing
      , plants = List.repeat defaultRows (List.repeat defaultColumns Blue)
      }
    , Cmd.batch
        [ Cmd.map (GridMsg "0") makeGrid
        , Cmd.map (GridMsg "1") makeGrid
        , generateRandomColors defaultRows defaultColumns
        ]
    )


incrementModel : Model -> Model
incrementModel model =
    { grids = Dict.map (\_ -> stepGrid) model.grids
    , settings = model.settings
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
    , animation = model.animation
    , plants = model.plants
    }


decrementModel : Model -> Model
decrementModel model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    , plants = model.plants
    }


go : Model -> Model
go model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Just defaultTiming
    , plants = model.plants
    }


stop : Model -> Model
stop model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Nothing
    , plants = model.plants
    }


setPlants : Model -> List (List Plant) -> Model
setPlants model plants =
    { grids = model.grids
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
      , plants = model.plants
      }
    , Cmd.map (GridMsg gridId) cmd
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
