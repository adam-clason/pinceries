module Groceries.List exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Events exposing (onClick, onMouseOver, onMouseOut)
import Html.Attributes exposing (id, attribute, type_, class, src, value, href, style)
import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)

view : GroceryList -> Html Msg
view groceryList =
    let 
        categories = 
            List.foldr categorize Dict.empty groceryList.list
                |> Dict.toList

    in
        div [ class "mini-grocery-list" ]
            [ div [ id "grocery-list" ]
                [ ul [ class "vertical menu" ]
                    (List.map category categories)  
                ]   
            ]
       
category : (String, List Ingredient) -> Html Msg 
category (categoryName, ingredients) =
    li [ ]
        [ a [ ] 
            [ span [ class "category-name" ] [ text (categoryName) ]
            , ul [ ]
                (List.map ingredientLi ingredients)
            ]
        ]

ingredientLi : Ingredient -> Html Msg 
ingredientLi ingredient =
    li [] 
        [ a [] [ text (ingredient.amount ++ " " ++ ingredient.name) ] ]


categorize : Ingredient -> Dict String (List Ingredient) -> Dict String (List Ingredient)
categorize ingredient acc = 
    Dict.update ingredient.category 
        (
            \maybe -> 
                case maybe of 
                    Just ingredients -> 
                        Just (ingredient :: ingredients)
                    Nothing -> 
                        Just [ ingredient ]
        ) acc
