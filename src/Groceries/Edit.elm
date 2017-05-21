module Groceries.Edit exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Events exposing (onClick, onMouseOver, onMouseOut)
import Html.Attributes exposing (classList, for, name, id, attribute, type_, class, src, value, href, style, type_)
import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)

view : GroceryList -> Html Msg
view groceryList =
    div [ class "grocery-list-container container clearfix row" ]
        [ div [ class "columns small-10 small-centered" ]
            [ arrangeBy groceryList.arrangeBy 
            , groceryListContents groceryList
            ]
        ]

arrangeBy : ArrangeBy -> Html Msg 
arrangeBy arrangeBy = 
    div [ class "arrange-by "] 
        [ span [ class "options-label" ] [ text "Arrange By:" ]
        , div [ class "options" ] 
            [ div [ classList [ ("option", True), ("selected", (arrangeBy == Category) ) ], onClick (ForSelf (SwitchTo Category)) ] [ text "Category" ]  
            , div [ classList [ ("option", True), ("selected", (arrangeBy == Pin) ) ], onClick (ForSelf (SwitchTo Pin)) ] [ text "Pin" ]  
            ]
        ]


groceryListContents : GroceryList -> Html Msg 
groceryListContents groceryList =
    let 
        ingredients =
            case groceryList.arrangeBy of
                Pin -> groupByPin groceryList
                Category -> groupByPin groceryList

    in 
        div []
            [ ul [] (List.map (category groceryList) ingredients)
            ]


category : GroceryList -> (String, List Ingredient) -> Html Msg 
category groceryList (categoryName, ingredients) =
    let 
        ingredientPin =
            Dict.get categoryName groceryList.pins
        pinHtml = 
             case ingredientPin of 
                Just pin ->
                    div [ class "cat-name" ] 
                        [ text (pin.note ) 
                        , img [ src pin.img ] [] 
                        ]
                Nothing ->
                    text ""
    in
        li [ class "flex-row" ]
            [ div [ class "grocery-flex-container" ] 
                [ div [ class "category-name" ] 
                   [ pinHtml ]
                , div [ class "ingredients" ]
                    [ ul [ ]
                        (List.map ingredientLi ingredients)
                    ] 
                ] 
            ]


ingredientLi : Ingredient -> Html Msg 
ingredientLi ingredient =
    li [] 
        [ a [] 
            [ input [ type_ "checkbox", id ingredient.id ] []
            , label [ for ingredient.id ] [ text ( ingredient.amount ++ " " ++ ingredient.name) ] 
            ]
        ]

groupByPin : GroceryList -> List (String, List Ingredient)
groupByPin groceryList =
    List.foldr foldrPin Dict.empty groceryList.list
        |> Dict.toList

foldrPin ingredient acc =
    Dict.update ingredient.pinId 
        (
            \maybe -> 
                case maybe of 
                    Just ingredients -> 
                        Just (ingredient :: ingredients)
                    Nothing -> 
                        Just [ ingredient ]
        ) acc


    



