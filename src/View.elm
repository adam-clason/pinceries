module View exposing (..)

import String
import Html exposing (Html, a, div, text, nav, button, span, ul, li, form, p, h3, img)
import Html.Attributes exposing (class, attribute, href, action, type_, src)
import Messages exposing (Msg(..), translationDictionary)
import Models exposing (Model)
import Boards.List
import Pins.List
import Groceries.List
import Pins.Update exposing (..)

import Routing exposing (Route(..), InnerRoute(..))


pinsTranslator = Pins.Update.translator translationDictionary

view : Model -> Html Msg
view model =
    div []
        [ navbar model
        , page model 
        ]


page : Model -> Html Msg
page model =
    case model.route of

        Authenticated innerRoute ->
            if String.isEmpty model.accessToken then
                loginView  
            else 
                case innerRoute of
                    BoardsRoute ->
                        Html.map BoardsMsg (Boards.List.view model.boards)

                    BoardRoute id ->
                        Html.map pinsTranslator (Pins.List.view model.pins)

                    Authorize authCode ->
                        accessView

        Anonymous innerRoute ->
            case innerRoute of
                    BoardsRoute ->
                        Html.map BoardsMsg (Boards.List.view model.boards)

                    BoardRoute id ->
                        Html.map pinsTranslator (Pins.List.view model.pins)

                    Authorize authCode ->
                        accessView

        NotFoundRoute ->
            notFoundView


navbar : Model -> Html Msg
navbar model = 
    nav [ class "top-bar" ]
        [ div [ class "top-bar-left" ] 
            [ ul [ class "dropdown menu" ]
                [ li [ class "menu-text" ] [ text "Pinceries"] ]
                ]
        , div [ class "top-bar-right" ]
            [ ul [ class "menu dropdown" ] 
                [ li [] 
                    [ groceryList model ]

                ]
            ]
        ]


groceryList : Model -> Html Msg
groceryList model = 
    Html.map GroceriesMsg (Groceries.List.view model.groceryList)


accessView : Html msg
accessView =
    div [ class "container"]
        [ text "ACCESSING PLZ"
        ]

loginView : Html msg 
loginView = 
    div [ class "login-container" ] 
        [ div [ class "login-form" ]
            [ h3 [] [ text "Hi There!"]
            , p [] [ text "We are here to help you gather your next grocery list as easily and quickly as possible. Please login with Pinterest to get started!" ]
            , a [ href "https://api.pinterest.com/oauth?response_type=code&client_id=4869854870047304425&state=kh123&scope=read_public&redirect_uri=https://localhost:3000/authorize", class "button" ] 
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

