module Pins.List exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (classList, type_, class, src, value, href, style)
import Pins.Models exposing (..)
import Pins.Messages exposing (..)
import Groceries.Models exposing (..)

view : List Pin -> GroceryList -> Html Msg
view pins groceryList =
    div [ class "container" ]
        [ list pins groceryList ]


list : List Pin -> GroceryList ->  Html Msg
list pins groceryList =

    let   
        thumbnailView =
            pinThumbnail groceryList
    in
        div [ class "row small-up-2 medium-up-3 larg-up-4" ]
            (List.map thumbnailView pins)


pinThumbnail : GroceryList -> Pin -> Html Msg
pinThumbnail groceryList pin  =

    let 
        pinInGroceryList =
           List.any (\i -> i.pinId == pin.id) groceryList.list 
        pinHasIngredientsMetadata = 
            List.length pin.ingredients > 0 

    in
        div [ class "column pin" ]
            [ div [ classList [ ("pin-image", True), ("not-available", not pinHasIngredientsMetadata) ] ]
                [ notAvailableMessage pinHasIngredientsMetadata
                , img [ src pin.img ] [] 
                ]
            , div [ class "caption" ] 
                [ h5 [] [ text pin.note ] ]
            , addRemoveButton pinInGroceryList pinHasIngredientsMetadata pin
            ]
 
notAvailableMessage : Bool -> Html Msg 
notAvailableMessage pinHasIngredientsMetadata =
    if not pinHasIngredientsMetadata then 
        div [ class "msg" ] [ text "Not Available"]
    else 
        Html.text ""


addRemoveButton : Bool -> Bool -> Pin -> Html Msg
addRemoveButton pinInGroceryList pinHasIngredientsMetadata pin = 
    if pinHasIngredientsMetadata then
        if pinInGroceryList then 
            button [ type_ "button", class "button ", onClick (ForParent (RemoveFromGroceryList pin) ) ] 
                [ text "Remove"
                , i [ class "fa fa-close" ] [] 
                ] 
        else 
            button [ type_ "button", class "button ", onClick (ForParent (AddToGroceryList pin) ) ] 
                [ text "Add" 
                , i [ class "fa fa-check" ] []
                ] 
    else 
        Html.text ""     


       