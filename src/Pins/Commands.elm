module Pins.Commands exposing (..)

import Http
import Json.Decode exposing (..)
import Task
import Models exposing (Model)
import Pins.Models exposing (PinId, Pin, Category, Ingredient)
import Boards.Models exposing (BoardId, Board)
import Pins.Messages exposing (..)

fetchPins : Model -> BoardId -> Cmd Msg
fetchPins model boardId =
    Http.get (fetchPinsUrl model.accessToken boardId) collectionDecoder 
        |> Http.send (\a -> ForSelf (FetchAllDone a))

fetchPinsUrl : String -> BoardId -> String
fetchPinsUrl accessToken boardId =
    let url = 
        "https://api.pinterest.com/v1/boards/" ++ boardId ++ "/pins/?access_token=" ++ accessToken ++ "&fields=id%2Clink%2Cnote%2Curl%2Cmetadata%2Cimage"
    in
        url

collectionDecoder : Decoder (List Pin)
collectionDecoder =
    at ["data"] ( list memberDecoder)


memberDecoder : Decoder Pin
memberDecoder =
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
    map2 Ingredient
        (field "amount" string)
        (field "name" string)




