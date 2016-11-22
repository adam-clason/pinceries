module Main exposing (..)

import Navigation
import Messages exposing (Msg(..), translationDictionary)
import Models exposing (Model, initialModel)
import View exposing (view)
import Update exposing (update)
import Boards.Commands exposing (fetchAll)
import Pins.Commands exposing (fetchPins)
import Pins.Update
import Routing exposing (Route(..))

pinsTranslator = Pins.Update.translator translationDictionary

init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        currentRoute =
            Routing.routeFromResult result
        routeCommand = 
            commandFromRoute currentRoute

    in
        ( initialModel currentRoute, routeCommand )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        currentRoute =
            Routing.routeFromResult result
        routeCommand = 
            commandFromRoute currentRoute

    in
        ( { model | route = currentRoute }, routeCommand )



commandFromRoute : Route ->  Cmd Msg
commandFromRoute currentRoute  =
    case currentRoute of 
        BoardsRoute ->
            Cmd.map BoardsMsg fetchAll

        BoardRoute id ->
            Cmd.map pinsTranslator (fetchPins id)
            
        NotFoundRoute ->
            Cmd.none


-- MAIN

main : Program Never
main =
    Navigation.program Routing.parser
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }