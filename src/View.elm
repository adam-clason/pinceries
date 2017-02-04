module View exposing (..)

import String
import Html exposing (Html, a, div, text, nav, button, span, ul, li, form, p, h3, img, i)
import Html.Attributes exposing (class, attribute, href, action, type_, src, id)
import Messages exposing (Msg(..), pinsTranslationDictionary, groceriesTranslationDictionary)
import Models exposing (Model)
import Boards.List
import Pins.List
import Groceries.List
import Alerts.View
import Pins.Update exposing (..)
import Groceries.Update exposing (..)
import Alerts.Update exposing (..)

import Routing exposing (Route(..), InnerRoute(..))


pinsTranslator = Pins.Update.translator pinsTranslationDictionary
groceriesTranslator = Groceries.Update.translator groceriesTranslationDictionary

view : Model -> Html Msg
view model =
    div []
        [ navbar model
        , div [ id "content" ] 
            [ alerts model 
            , page model 
            ]
        ]


page : Model -> Html Msg
page model =
    case model.route of

        Authenticated innerRoute ->
            if String.isEmpty model.accessToken then
                loginView model
            else 
                case innerRoute of
                    BoardsRoute ->
                        Html.map BoardsMsg (Boards.List.view model.boards)

                    BoardRoute id ->
                        Html.map pinsTranslator (Pins.List.view model.pins)

                    GroceriesRoute ->
                        Html.map groceriesTranslator (Groceries.List.view model.groceryList)

                    Authorize authCode ->
                        accessView

        Anonymous innerRoute ->
            case innerRoute of
                BoardsRoute ->
                    Html.map BoardsMsg (Boards.List.view model.boards)

                BoardRoute id ->
                    Html.map pinsTranslator (Pins.List.view model.pins)

                GroceriesRoute ->
                    Html.map groceriesTranslator (Groceries.List.view model.groceryList)

                Authorize authCode ->
                    accessView

        NotFoundRoute ->
            notFoundView


navbar : Model -> Html Msg
navbar model = 
    div [] 
    [ nav [ class "top-bar" ]
        [ div [ class "top-bar-left" ] 
            [ ul [ class "dropdown menu" ]
                [ li [ class "menu-text" ] [ text "Pinceries"] ]
                ]
        , div [ class "top-bar-right" ]
            [ ul [ class "menu dropdown" ] 
                [ li [] 
                    [ div [ class "mini-list-link" ]
                        [ i [ class "fa fa-shopping-cart" ] [] 
                        ]  
                    ]

                ]
            ]
        ]
    , groceryList model
    ]
    

alerts : Model -> Html Msg 
alerts model = 
    Html.map AlertsMsg (Alerts.View.view model.alerts)

groceryList : Model -> Html Msg
groceryList model = 
    Html.map groceriesTranslator (Groceries.List.view model.groceryList)


accessView : Html msg
accessView =
    div [ class "container"]
        [ text "ACCESSING PLZ"
        ]

loginView : Model -> Html msg 
loginView model = 
    div [ class "login-container" ] 
        [ div [ class "login-form" ]
            [ h3 [] [ text "Hi There!"]
            , p [] [ text "We are here to help you gather your next grocery list as easily and quickly as possible. Please login with Pinterest to get started!" ]
            , a [ href ("https://api.pinterest.com/oauth?response_type=code&client_id=4869854870047304425&state=kh123&scope=read_public&redirect_uri=" ++ model.pinterestRedirectUrl), class "button" ] 
                [ span [] [ text "Login with Pinterest" ]
                , img [ src "./pinterest_badge.png" ] [] 
                ] 
            ]
        ]

notFoundView : Html msg
notFoundView =
    div [ class "container" ]
        [ div [ class "columns" ]
            [ text "Not found" ]
        ]

