module Pins.Commands exposing (..)

import Http
import Json.Decode exposing (..)
import Task
import Process exposing (spawn)
import Models exposing (Model)
import Pins.Models exposing (PinsList)
import Boards.Models exposing (BoardId, Board)
import Pinterest.Models exposing (Pin, Ingredient, Category)
import Pins.Messages exposing (..)

fetchPins : PinsList -> String -> Cmd Msg
fetchPins pinsList nextUrl =
    Http.get (fetchPinsUrl pinsList nextUrl) (pinsListDecoder pinsList)
        |> Http.send (\a -> ForSelf (FetchAllDone a))

fetchPinsUrl : PinsList -> String -> String
fetchPinsUrl pinsList nextUrl =
    let url = 
        if String.length nextUrl > 0 then 
            nextUrl
        else 
            "https://api.pinterest.com/v1/boards/" ++ pinsList.boardId ++ "/pins/?access_token=" ++ pinsList.accessToken ++ "&fields=id%2Clink%2Cnote%2Curl%2Cmetadata%2Cimage"
    in
        url

pinsListDecoder : PinsList -> Decoder (PinsList)
pinsListDecoder pinsList  =
    map4 PinsList
        (succeed pinsList.accessToken)
        (succeed pinsList.boardId)
        (at ["data"] (list pinDecoder))
        (at ["page"] (field "next" string))



pinDecoder : Decoder Pin
pinDecoder =
    map5 Pin
        (field "id" string)
        (field "url" string)
        (at ["image", "original"] (field "url" string))
        (field "note" string)
        (oneOf [ at ["metadata", "recipe", "ingredients"] categoryDecoder, succeed [] ]) 
        

categoryDecoder : Decoder (List Category)
categoryDecoder =
    list <|
        map2 Category
            (field "category" string)
            (at ["ingredients"] (list ingredientDecoder) )

ingredientDecoder: Decoder Ingredient
ingredientDecoder =
    map3 Ingredient
        (succeed "")
        (field "amount" string)
        (field "name" string)




