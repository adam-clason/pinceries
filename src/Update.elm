port module Update exposing (..)

import Messages exposing (Msg(..), pinsTranslationDictionary, groceriesTranslationDictionary)
import Models exposing (Model, User, userFromJwt)
import Cmd.Extra

import Groceries.Messages
import Pins.Messages exposing (OutMsg(..))
import Alerts.Messages

import Task
import Navigation
import Commands
import Storage
import Pins.Commands
import Boards.Commands
import Boards.Update
import Pins.Update
import Alerts.Update
import Groceries.Update
import Groceries.Commands
import Routing exposing (Route(..), InnerRoute(..))

pinsTranslator = Pins.Update.translator pinsTranslationDictionary
groceriesTranslator = Groceries.Update.translator groceriesTranslationDictionary


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
                ( { model | groceryList = updatedGroceryList }, Cmd.map groceriesTranslator cmd)

        AlertsMsg subMsg ->
            let
                ( updatedAlerts, cmd ) = 
                    Alerts.Update.update subMsg model.alerts 
            in 
                ( { model | alerts = updatedAlerts }, Cmd.map AlertsMsg cmd)

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
                            groceryList =
                                model.groceryList

                            updatedGroceryList = 
                                { groceryList | id = updatedUser.activeGroceryListId, jwt = authorizeInfo.jwt }

                            updatedModel =
                                { model | user = updatedUser, groceryList = updatedGroceryList, accessToken = authorizeInfo.accessToken, jwt = authorizeInfo.jwt }

                            commands =
                                [ Storage.setAccessToken authorizeInfo.accessToken
                                , Storage.setJwt authorizeInfo.jwt 
                                , Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList updatedModel.groceryList)
                                , Navigation.newUrl "/#boards"
                                ]
                         in 
                            (updatedModel, Cmd.batch commands)   

                    Err jwtError ->
                        (model, Cmd.none)

        Authorized (Err error) ->
            ( model, Cmd.none ) 

        AuthorizationError ->
            ({ model | jwt = "", accessToken = "" }, Cmd.Extra.message (AlertsMsg Alerts.Messages.AuthorizationError))


initCommand : Model -> Route ->  Cmd Msg
initCommand model currentRoute  =
    case currentRoute of 
        Authenticated innerRoute ->
            if authenticated model then
             case innerRoute of 
                BoardsRoute ->
                    Cmd.batch 
                        [ Cmd.map BoardsMsg (Boards.Commands.fetchAll model)
                        , Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList model.groceryList)
                        ]
                        
    
                BoardRoute id ->
                    Cmd.batch 
                        [ Cmd.map pinsTranslator (Pins.Commands.fetchPins model id)
                        , Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList model.groceryList)
                        ]

                _ ->
                    Cmd.none
            else 
                Cmd.none


        Anonymous innerRoute ->
             case innerRoute of 
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

                _ ->
                    Cmd.none

        NotFoundRoute ->
            Cmd.none


commandFromRoute : Model -> Route ->  Cmd Msg
commandFromRoute model currentRoute  =
    case currentRoute of 
        Authenticated innerRoute ->
             case innerRoute of 
                BoardsRoute ->
                    Cmd.map BoardsMsg (Boards.Commands.fetchAll model)
                        
                BoardRoute id ->
                    Cmd.map pinsTranslator (Pins.Commands.fetchPins model id)
                       
                _ ->
                    Cmd.none

        Anonymous innerRoute ->
             case innerRoute of 
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

                _ ->
                    Cmd.none

        NotFoundRoute ->
            Cmd.none


authenticated : Model -> Bool
authenticated model =
    String.length model.accessToken > 0 && String.length model.jwt > 0


