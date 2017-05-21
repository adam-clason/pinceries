module Pinterest.Commands exposing (..)

import Http
import Json.Decode exposing (..)
import Pinterest.Models exposing (..)

fetchPinsForIngredients : String -> (Result Http.Error Pin -> msg) -> List String -> Cmd msg
fetchPinsForIngredients accessToken generator pinIds  = 
    let 
        httpRequests =
            List.map (\pid -> Http.get (fetchPinsForIngredientsUrl accessToken pid) pinDecoder) pinIds
        commands = 
            List.map (\r -> r |> Http.send generator) httpRequests
    in
        Cmd.batch commands

fetchPinsForIngredientsUrl : String -> String -> String
fetchPinsForIngredientsUrl accessToken pinId = 
    let url = 
        "https://api.pinterest.com/v1/pins/" ++ pinId ++ "/?access_token=" ++ accessToken ++ "&fields=id%2Clink%2Cnote%2Curl%2Cmedia%2Cmetadata%2Cimage"
    in
        url

pinDecoder : Decoder Pin
pinDecoder =
    map5 Pin
        (at ["data"] (field "id" string))
        (at ["data"] (field "url" string))
        (at ["data", "image", "original"] (field "url" string))
        (at ["data"] (field "note" string))
        (at ["data"] (oneOf [ at ["metadata", "recipe", "ingredients"] categoryDecoder, succeed [] ]))    

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