port module Update exposing (..)

import Messages exposing (Msg(..), translationDictionary)
import Models exposing (Model)

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
                decodeJwtResult = 
                    Commands.decodeJwt authorizeInfo.jwt

            in 
                case decodeJwtResult of 
                    Ok updatedUser ->

                        let logged = 
                            Debug.log "success" "It was a success"

                        in
                            ({ model | user = updatedUser, accessToken = authorizeInfo.accessToken, jwt = authorizeInfo.jwt }
                             , Cmd.batch [ Storage.setAccessToken authorizeInfo.accessToken, Storage.setJwt authorizeInfo.jwt ] )

                    Err jwtError ->

                        case jwtError of  
                            HttpError error ->
                                let logged =
                                    Debug.log "http" error
                                in 
                                    ( model, Cmd.none )

                            Unauthorized ->
                                let logged =
                                    Debug.log "http" "unauthorized"
                                in 
                                    ( model, Cmd.none )

                            TokenExpired ->
                                let logged =
                                    Debug.log "http" "tokenexpired"
                                in 
                                    ( model, Cmd.none )

                            TokenNotExpired ->
                                let logged =
                                    Debug.log "http" "tokennotexpired"
                                in 
                                    ( model, Cmd.none )

                            TokenProcessingError error ->
                                let logged =
                                    Debug.log "tokenprocessing" error
                                in 
                                    ( model, Cmd.none  )

                            TokenDecodeError error ->
                                let logged =
                                    Debug.log "tokendecode" error
                                in 
                                    ( model, Cmd.none )

        Authorized (Err error) ->
            
            let logged =
                Debug.log "Authorized Error" error
            
            in 
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





