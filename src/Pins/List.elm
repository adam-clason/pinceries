module Pins.List exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (type_, class, src, value, href, style)
import Pins.Models exposing (..)
import Pins.Messages exposing (..)

view : List Pin -> Html Msg
view pins =
    div [ class "container" ]
        [ h1 [ class "columns" ] 
            [ span [] [ text "Pins " ]
            , small [] [ text "Select the pins to add to your grocery list.."]
            ] 
        , list pins 
        ]


list : List Pin -> Html Msg
list pins =
    div [ class "row small-up-2 medium-up-3 larg-up-4" ]
        (List.map pinThumbnail pins)


pinThumbnail : Pin -> Html Msg
pinThumbnail pin =
    div [ class "column pin" ]
        [ div [ class "pin-image" ]
            [ img [ src pin.img ] [] ]
        , div [ class "caption" ] 
            [ h5 [] [ text pin.note ] ]
        , button [ type_ "button", class "button ", onClick (ForParent (AddToGroceryList pin) ) ] [ text "Add" ] 
        ]
      
            


       