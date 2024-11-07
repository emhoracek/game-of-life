module Main exposing (..)

import Browser
import Garden.Model exposing (Model, Msg)
import Garden.Update exposing (init, subscriptions, update)
import Garden.View exposing (view)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
