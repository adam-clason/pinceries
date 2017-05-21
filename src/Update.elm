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
                ( updatedPinsList, cmd) =
                    Pins.Update.update subMsg model.pinsList
            in
        
                ( { model | pinsList = updatedPinsList }, Cmd.map pinsTranslator cmd)


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
                updatedModel = 
                    { model | route = updatedRoute }
                modelAndCommands =
                    modelAndCommandsFromRoute updatedModel updatedRoute
            in
                modelAndCommands

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

                            pinsList = 
                                model.pinsList 

                            updatedGroceryList = 
                                { groceryList | id = updatedUser.activeGroceryListId, jwt = authorizeInfo.jwt }

                            updatedPinsList = 
                                { pinsList | accessToken = authorizeInfo.accessToken }

                            updatedModel =
                                { model | user = updatedUser, groceryList = updatedGroceryList, pinsList = updatedPinsList, accessToken = authorizeInfo.accessToken, jwt = authorizeInfo.jwt }

                            commands =
                                [ Storage.setAccessToken authorizeInfo.accessToken
                                , Storage.setJwt authorizeInfo.jwt 
                                , Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList updatedModel.groceryList)
                                , Navigation.newUrl "/#boards"
                                ]
                         in 
                            (updatedModel, Cmd.batch commands)   

                    Err jwtError ->
                        ({ model | jwt = "", accessToken = "" }, Cmd.Extra.message (AlertsMsg Alerts.Messages.AuthorizationError))

        Authorized (Err error) ->
            ({ model | jwt = "", accessToken = "" }, Cmd.Extra.message (AlertsMsg Alerts.Messages.AuthorizationError))

        AuthorizationError ->
            ({ model | jwt = "", accessToken = "" }, Cmd.Extra.message (AlertsMsg Alerts.Messages.AuthorizationError))


initModelAndCommands : Model -> Route ->  (Model, Cmd Msg)
initModelAndCommands model currentRoute  =
    case currentRoute of 
        Authenticated innerRoute ->
            if authenticated model then
             case innerRoute of 
                BoardsRoute ->
                    let 
                        routeCommands = 
                            Cmd.batch 
                                [ Cmd.map BoardsMsg (Boards.Commands.fetchAll model)
                                , Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList model.groceryList)
                                ]
                    in 
                        (model, routeCommands)

    
                BoardRoute id ->
                    let 
                        pinsList =
                            model.pinsList 
                        updatedPinsList = 
                            { pinsList | boardId = id, pins = [] }
                        routeCommands = 
                            Cmd.batch 
                                [ Cmd.map pinsTranslator (Pins.Commands.fetchPins updatedPinsList "")
                                , Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList model.groceryList)
                                ]
                        updatedModel = 
                            { model | pinsList = updatedPinsList }
                    in 
                        (updatedModel, routeCommands)

                GroceriesRoute ->
                    (model, Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList model.groceryList))

                _ ->
                    (model, Cmd.none)
            else 
                (model, Cmd.none)


        Anonymous innerRoute ->
             case innerRoute of 
                Authorize (Just authCode) -> 
                    let 
                        fetchToken =
                            Commands.fetchAccessToken model authCode
                        fetchJwt =
                            Commands.fetchPinceriesApiJwt model
                    in
                        (model, fetchToken |> Task.andThen fetchJwt |> Task.attempt Authorized)

                Authorize Nothing ->
                    (model, Cmd.none)

                _ ->
                    (model, Cmd.none) 

        NotFoundRoute ->
            (model, Cmd.none)


modelAndCommandsFromRoute : Model -> Route ->  (Model, Cmd Msg)
modelAndCommandsFromRoute model currentRoute =
    case currentRoute of 
        Authenticated innerRoute ->
             case innerRoute of 
                BoardsRoute ->
                    (model, Cmd.map BoardsMsg (Boards.Commands.fetchAll model))
                        
                BoardRoute id ->
                    let 
                        pinsList = 
                            model.pinsList
                        updatedPinsList = 
                            { pinsList | pins = [], boardId = id }
                        commands = 
                            Cmd.map pinsTranslator (Pins.Commands.fetchPins updatedPinsList "")
                        updatedModel =
                            { model | pinsList = updatedPinsList }
                    in
                        (updatedModel, commands) 

                GroceriesRoute -> 
                    (model, Cmd.map groceriesTranslator (Groceries.Commands.fetchGroceryList model.groceryList))
                    
                _ ->
                    (model, Cmd.none)

        Anonymous innerRoute ->
             case innerRoute of 
                Authorize (Just authCode) -> 
                    let 
                        fetchToken =
                            Commands.fetchAccessToken model authCode
                        fetchJwt =
                            Commands.fetchPinceriesApiJwt model
                    in
                        (model, fetchToken |> Task.andThen fetchJwt |> Task.attempt Authorized)

                Authorize Nothing ->
                    (model, Cmd.none)

                _ ->
                    (model, Cmd.none)

        NotFoundRoute ->
            (model, Cmd.none)


authenticated : Model -> Bool
authenticated model =
    String.length model.accessToken > 0 && String.length model.jwt > 0


