module Main exposing (..)

import Browser
import CellTeams.Update exposing (init)
import CellTeams.Update exposing (update, subscriptions)
import CellTeams.View exposing (view)
import CellTeams.Model exposing (Model, Msg)


cellTeamsMain : Program () Model Msg
cellTeamsMain =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

