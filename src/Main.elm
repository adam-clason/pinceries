module Main exposing (..)

import Navigation
import Storage
import Messages exposing (Msg(..))
import Models exposing (Model, Flags, initialModel)
import View exposing (view)
import Update exposing (update, initModelAndCommands, pinsTranslator)
import Boards.Commands exposing (fetchAll)
import Pins.Commands exposing (fetchPins)
import Pins.Update
import Routing exposing (Route(..), InnerRoute(..))


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parser location |> Routing.routeFromMaybe
        model =
            initialModel flags currentRoute
        modelAndCommands = 
            initModelAndCommands model currentRoute

    in
        modelAndCommands


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map pinsTranslator Pins.Update.subscriptions 

-- MAIN

main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }