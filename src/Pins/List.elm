module Pins.List exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (classList, type_, class, src, value, href, style, attribute)
import Pins.Models exposing (..)
import Pins.Messages exposing (..)
import Groceries.Models exposing (..)

view : PinsList -> GroceryList -> Html Msg
view pins groceryList =
    div [ class "container" ]
        [ list pins groceryList ]


list : PinsList -> GroceryList ->  Html Msg
list pinsList groceryList =

    let   
        thumbnailView =
            pinThumbnail groceryList
    in
        div [ ]
            [ div [ class "row small-up-2 medium-up-3 larg-up-4" ] (List.map thumbnailView pinsList.pins)
            , div [ class "row bottom small-up-1 medium-up-1 large-up-1", attribute "data-nexturl" pinsList.nextUrl ] 
                [ div [ class "column spinner hidden" ] 
                    [ img [ src "./spin.svg" ] [] 
                    ] 
                ] 
            ]
           

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


       