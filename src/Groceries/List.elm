module Groceries.List exposing (..)

import Dict
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (type', class, src, value, href, style)
import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)

view : GroceryList -> Html Msg
view groceryList =
    div [ class "mini-grocery-list" ]
        [ i [ class "fa fa-shopping-cart" ] [] 
        , div [ class "count-container" ] 
            [ div [ class "count-wrapper"] [ span [ class "count" ] [ text "2" ] ]
            ]
        , ul [ class "list-group"]
            (List.map category (Dict.toList groceryList))
        ]
        
    
        

category : (String, List Ingredient) -> Html Msg 
category (name, ingredients) =
    li [ class "list-unstyled" ]
        [ h4 [ ] [ text name ]
        , div [ ] 
            [ ul [ class "list-group" ] (List.map ingredientsListItem ingredients) ]
        ]

ingredientsListItem : Ingredient -> Html Msg
ingredientsListItem ingredient =
    li [ class "list-group-item" ] 
        [ text (ingredient.name ++ " " ++ ingredient.amount) 
        , a [ class "pull-right", onClick (RemoveIngredient ingredient) ] [ i [ class "glyphicon glyphicon-remove" ] [] ] 
        ]

       