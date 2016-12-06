module Groceries.List exposing (..)

import Dict
import Html exposing (..)
import Html.Events exposing (onClick, onMouseOver, onMouseOut)
import Html.Attributes exposing (attribute, type_, class, src, value, href, style)
import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)

view : GroceryList -> Html Msg
view groceryList =
    div [ class "mini-grocery-list", onMouseOver Show, onMouseOut Show, onClick Show ]
        [ i [ class "fa fa-shopping-cart" ] [] 
        , div [ class "count-container" ] 
            [ div [ class "count-wrapper"] [ span [ class "count" ] [ text (toString groceryList.count) ] ]
            ]
        , div [ class (groceryListClassName groceryList.show) ]
            [ ul [ class "vertical menu" ]
                (List.map category groceryList.list)  
            ]
        ]
 
groceryListClassName : Bool -> String
groceryListClassName showMenu = 
    if showMenu == True then
        "grocery-list-wrapper show"
    else 
        "grocery-list-wrapper slide-up"


category : Ingredient -> Html Msg 
category ingredient =
    li [ ]
        [ a [ ] 
            [ text (ingredient.name ++ " " ++ ingredient.amount)
            ]
        ]

       