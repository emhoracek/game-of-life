module Main exposing (..)

import Browser
import Garden.Update exposing (init)
import Garden.Update exposing (update, subscriptions)
import Garden.View exposing (view)
import Garden.Model exposing (Model, Msg)


cellTeamsMain : Program () Model Msg
cellTeamsMain =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

