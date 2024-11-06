module CellTeams.Update exposing (..)

import Browser.Events
import Dict
import CellTeams.Grid.Model exposing (CellState(..), deadGrid, stepGrid)
import CellTeams.Grid.Update exposing (GridMsg, defaultColumns, defaultRows, makeGrid, updateGrid)
import CellTeams.Model exposing (GridId, Model, Msg(..))


defaultTiming : Int
defaultTiming =
    100


init : () -> ( Model, Cmd Msg )
init _ =
    ( { grids = Dict.fromList [ ( "0", deadGrid defaultRows defaultColumns ), ( "1", deadGrid defaultRows defaultColumns ) ]
      , settings = { rows = defaultRows, columns = defaultColumns }
      , timeInCycle = 0
      , animation = Nothing
      }
    , Cmd.batch [ Cmd.map (GridMsg "0") makeGrid, Cmd.map (GridMsg "1") makeGrid ]
    )


incrementModel : Model -> Model
incrementModel model =
    { grids = Dict.map (\_ -> stepGrid) model.grids
    , settings = model.settings
    , timeInCycle = Maybe.withDefault defaultTiming model.animation
    , animation = model.animation
    }


decrementModel : Model -> Model
decrementModel model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = model.timeInCycle - 1
    , animation = model.animation
    }


go : Model -> Model
go model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Just defaultTiming
    }


stop : Model -> Model
stop model =
    { grids = model.grids
    , settings = model.settings
    , timeInCycle = defaultTiming
    , animation = Nothing
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
