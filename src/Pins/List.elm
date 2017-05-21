module Pins.List exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (classList, type_, class, src, value, href, style, attribute)
import Pins.Models exposing (..)
import Pins.Messages exposing (..)
import Groceries.Models exposing (..)
import Pinterest.Models exposing (Pin)

view : PinsList -> List Groceries.Models.Ingredient -> Html Msg
view pins ingredients =
    div [ class "pins-container clearfix container" ]
        [ h1 [] [] 
        , div [ class "column grid-container"] [ list pins ingredients ] 
        ] 


list : PinsList -> List Groceries.Models.Ingredient ->  Html Msg
list pinsList ingredients =

    let   
        thumbnailView =
            pinThumbnail ingredients
    in
        div [ ]
            [ div [ class "row small-up-2 medium-up-3 larg-up-4" ] (List.map thumbnailView pinsList.pins)
            , div [ class "row bottom small-up-1 medium-up-1 large-up-1", attribute "data-nexturl" pinsList.nextUrl ] 
                [ div [ class "column spinner hidden" ] 
                    [ img [ src "./spin.svg" ] [] 
                    ] 
                ] 
            ]
           

pinThumbnail : List Groceries.Models.Ingredient -> Pin -> Html Msg
pinThumbnail ingredients pin  =

    let 
        pinInGroceryList =
           List.any (\i -> i.pinId == pin.id) ingredients 
        pinHasIngredientsMetadata = 
            List.length pin.ingredients > 0 

    in
        div [ class "column pin" ]
            [ div [ classList [ ("pin-image", True), ("not-available", not pinHasIngredientsMetadata) ] ]
                [ notAvailableMessage pinHasIngredientsMetadata
                , img [ src pin.img ] [] 
                ]
            , div [ class "caption" ] 
                [ p [] [ text pin.note ] ]
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


       