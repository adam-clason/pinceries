module Groceries.New exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, onMouseOver, onMouseOut, onInput)
import Html.Attributes exposing (attribute, type_, class, src, value, href, style, placeholder)
import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)

view : GroceryList -> Html Msg 
view groceryList = 
    div [ class "login-container" ] 
        [ div [ class "login-form" ]
            [ h3 [] [ text "Great!"]
            , p [] [ text "Let's get started with your first grocery list! You can enter a name for this grocery list if you want, or you can jump right into it." ]
            , div [ class "row" ] 
                [ div [ class "columns" ] 
                    [ input [ type_ "text", placeholder "Name (optional)", onInput Name ] []
                    ]
                ]
            , div [ class "row" ] [ input [ type_ "submit", onClick Save ] [] ]  
            ]
        ]
       