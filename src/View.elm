module View exposing (..)

import Html exposing (Html, a, div, text, nav, button, span, ul, li)
import Html.Attributes exposing (class, attribute)
import Html.App
import Messages exposing (Msg(..), translationDictionary)
import Models exposing (Model)
import Boards.List
import Pins.List
import Groceries.List
import Pins.Update exposing (..)

import Routing exposing (Route(..))


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
        BoardsRoute ->
            Html.App.map BoardsMsg (Boards.List.view model.boards)

        BoardRoute id ->
            Html.App.map pinsTranslator (Pins.List.view model.pins)

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
    Html.App.map GroceriesMsg (Groceries.List.view model.groceryList)



notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]

