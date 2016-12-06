port module Update exposing (..)

import Messages exposing (Msg(..), translationDictionary)
import Models exposing (Model, User, userFromJwt)

import Groceries.Messages
import Pins.Messages exposing (OutMsg(..))


import Debug
import Jwt exposing (JwtError(..))
import Task
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

        Authorized (Ok authorizeInfo) ->
            let 
                userResult = 
                    userFromJwt authorizeInfo.jwt

            in 
                case userResult of 
                    Ok updatedUser ->
                        let 
                            updatedModel =
                                { model | user = updatedUser, accessToken = authorizeInfo.accessToken, jwt = authorizeInfo.jwt }
                            commands =
                                [ Storage.setAccessToken authorizeInfo.accessToken
                                , Storage.setJwt authorizeInfo.jwt 
                                , Navigation.newUrl "#boards"
                                ]
                         in 
                            (updatedModel, Cmd.batch commands)   

                    Err jwtError ->
                        (model, Cmd.none)

        Authorized (Err error) ->
            ( model, Cmd.none )



commandFromRoute : Model -> Route ->  Cmd Msg
commandFromRoute model currentRoute  =
    case currentRoute of 
        Authenticated innerRoute ->
             case innerRoute of 
                BoardsRoute ->
                    Cmd.map BoardsMsg (Boards.Commands.fetchAll model)

                BoardRoute id ->
                    Cmd.map pinsTranslator (Pins.Commands.fetchPins model id)

                GroceriesRoute ->
                    Cmd.none

                Authorize (Just authCode) ->
                    let 
                        fetchToken =
                            Commands.fetchAccessToken model authCode
                        fetchJwt =
                            Commands.fetchPinceriesApiJwt model
                    in
                        fetchToken 
                            |> Task.andThen fetchJwt 
                            |> Task.attempt Authorized 

                Authorize Nothing ->
                    Cmd.none

        Anonymous innerRoute ->
             case innerRoute of 
                BoardsRoute ->
                    Cmd.map BoardsMsg (Boards.Commands.fetchAll model)

                BoardRoute id ->
                    Cmd.map pinsTranslator (Pins.Commands.fetchPins model id)

                GroceriesRoute ->
                    Cmd.none

                Authorize (Just authCode) -> 
                    let 
                        fetchToken =
                            Commands.fetchAccessToken model authCode
                        fetchJwt =
                            Commands.fetchPinceriesApiJwt model
                    in
                        fetchToken 
                            |> Task.andThen fetchJwt 
                            |> Task.attempt Authorized 

                Authorize Nothing ->
                    Cmd.none

        NotFoundRoute ->
            Cmd.none





