port module Update exposing (..)

import Messages exposing (Msg(..), translationDictionary)
import Models exposing (Model)

import Groceries.Messages
import Pins.Messages exposing (OutMsg(..))

import Navigation
import Commands
import Storage
import Pins.Commands
import Boards.Commands
import Boards.Update
import Pins.Update
import Groceries.Update
import Routing exposing (Route(..), InnerRoute(..))

pinsTranslator = Pins.Update.translator translationDictionary


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BoardsMsg subMsg ->
            let
                ( updatedBoards, cmd ) =
                    Boards.Update.update subMsg model.boards
            in
                ( { model | boards = updatedBoards }, Cmd.map BoardsMsg cmd )

        PinsMsg subMsg -> 
            let 
                ( updatedPins, cmd) =
                    Pins.Update.update subMsg model.pins
            in
        
                ( { model | pins = updatedPins }, Cmd.map pinsTranslator cmd)


        GroceriesMsg subMsg -> 
            let 
                ( updatedGroceryList, cmd ) =
                    Groceries.Update.update subMsg model.groceryList
            in 
                ( { model | groceryList = updatedGroceryList }, Cmd.map GroceriesMsg cmd)

        UrlChange location ->
            let 
                updatedRoute = 
                    Routing.routeFromMaybe <| Routing.parser location
                routeCommand =
                    commandFromRoute model updatedRoute
            in
                ( { model | route = updatedRoute }, routeCommand)

        AuthorizeDone (Ok updatedAccessToken) ->
            let 
                updatedModel = { model | accessToken = updatedAccessToken }

            in
                ( updatedModel, Cmd.batch 
                    [ Storage.setAccessToken updatedAccessToken
                    , Commands.fetchPinceriesApiJwt updatedModel
                    , Navigation.newUrl "/#boards"] )

        AuthorizeDone (Err _) ->
            ( model, Cmd.none)

        JwtReceived (Ok updatedJwt) ->
            ( { model | jwt = updatedJwt }, Storage.setJwt updatedJwt)

        JwtReceived (Err _) ->
            ( model, Cmd.none)


commandFromRoute : Model -> Route ->  Cmd Msg
commandFromRoute model currentRoute  =
    case currentRoute of 
        Authenticated innerRoute ->
             case innerRoute of 
                BoardsRoute ->
                    Cmd.map BoardsMsg (Boards.Commands.fetchAll model)

                BoardRoute id ->
                    Cmd.map pinsTranslator (Pins.Commands.fetchPins model id)

                Authorize (Just authCode) ->
                    (Commands.fetchAccessToken model authCode)

                Authorize Nothing ->
                    Cmd.none

        Anonymous innerRoute ->
             case innerRoute of 
                BoardsRoute ->
                    Cmd.map BoardsMsg (Boards.Commands.fetchAll model)

                BoardRoute id ->
                    Cmd.map pinsTranslator (Pins.Commands.fetchPins model id)

                Authorize (Just authCode) -> 
                    (Commands.fetchAccessToken model authCode)

                Authorize Nothing ->
                    Cmd.none

        NotFoundRoute ->
            Cmd.none





