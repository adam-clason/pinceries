module Pins.Commands exposing (..)

import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Pins.Models exposing (PinId, Pin, Category, Ingredient)
import Boards.Models exposing (BoardId, Board)
import Pins.Messages exposing (..)

fetchPins : BoardId -> Cmd Msg
fetchPins boardId =
    Http.get collectionDecoder (fetchPinsUrl boardId)
        |> Task.perform (\a -> ForSelf (FetchAllFail a)) (\a -> ForSelf (FetchAllDone a))

fetchPinsUrl : BoardId -> String
fetchPinsUrl boardId =
    let url = 
        "https://api.pinterest.com/v1/boards/" ++ boardId ++ "/pins/?access_token=AQzVp2qDwSy0lloYDh0R9rSNGHTJFIdhtkg6Q0FDjk-3wcA37wAAAAA&fields=id%2Clink%2Cnote%2Curl%2Cmetadata%2Cimage"
    in
        url

collectionDecoder : Decode.Decoder (List Pin)
collectionDecoder =
    Decode.at ["data"] (Decode.list memberDecoder)


memberDecoder : Decode.Decoder Pin
memberDecoder =
    Decode.object5 Pin
        ("id" := Decode.string)
        ("url" := Decode.string)
        (Decode.at ["image", "original"] ("url" := Decode.string))
        ("note" := Decode.string)
        (Decode.oneOf [ Decode.at ["metadata", "recipe", "ingredients"] categoryDecoder, Decode.succeed [] ]) 
        

categoryDecoder : Decode.Decoder (List Category)
categoryDecoder =
    Decode.list <|
        Decode.object2 Category
            ("category" := Decode.string)
            (Decode.at ["ingredients"] (Decode.list ingredientDecoder) )

ingredientDecoder: Decode.Decoder Ingredient
ingredientDecoder =
    Decode.object2 Ingredient
        ("amount" := Decode.string)
        ("name" := Decode.string)




