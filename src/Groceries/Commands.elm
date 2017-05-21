module Groceries.Commands exposing (..)

import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)
import Json.Decode exposing (..)
import Json.Encode
import Jwt
import Http exposing (jsonBody)

fetchGroceryList : GroceryList -> Cmd Msg    
fetchGroceryList model  =
    Jwt.get model.jwt (fetchGroceryListUrl model) (fetchGroceryListDecoder model)
        |> Jwt.send (\a -> ForSelf (FetchResult a))

fetchGroceryListUrl : GroceryList -> String
fetchGroceryListUrl model = 
    model.apiUrl ++ "/api/groceries/" ++ model.id


fetchGroceryListDecoder : GroceryList ->  Decoder GroceryList
fetchGroceryListDecoder currentModel = 
    map8 GroceryList
        (succeed currentModel.id)
        (succeed currentModel.name)
        (at ["ingredients"] (list ingredientDecoder))
        (succeed currentModel.pins)
        (succeed currentModel.arrangeBy)
        (succeed currentModel.apiUrl)
        (succeed currentModel.jwt)
        (succeed currentModel.accessToken)

ingredientDecoder : Decoder Ingredient
ingredientDecoder = 
    map7 Ingredient
        (field "_id" string)
        (field "name" string)
        (field "amount" string)
        (field "category" string)
        (field "count" int)
        (field "pinId" string)
        (field "checked" bool)

saveGroceryList : GroceryList -> Cmd Msg
saveGroceryList model =
    Jwt.post model.jwt (saveGroceryListUrl model) (saveGroceryListJsonBody model) addIngredientsResponseDecoder 
        |> Jwt.send (\a -> ForSelf (SaveResult a))

saveGroceryListJsonBody : GroceryList -> Http.Body
saveGroceryListJsonBody model =
    Json.Encode.object
        [ ("id", Json.Encode.string model.id)
        , ("name", Json.Encode.string model.id)
        , ("ingredients", Json.Encode.list <| 
            List.map 
                (
                    \i ->
                        Json.Encode.object
                            [ ("name", Json.Encode.string i.name)
                            , ("amount", Json.Encode.string i.amount)
                            , ("category", Json.Encode.string i.category)
                            , ("count", Json.Encode.int i.count)
                            , ("pinId", Json.Encode.string i.pinId)
                            , ("checked", Json.Encode.bool i.checked)
                            ]
                ) model.list
          )
        ]
    |> jsonBody


saveGroceryListUrl : GroceryList -> String 
saveGroceryListUrl model =
    (model.apiUrl ++ "/api/groceries/" ++ model.id)

addIngredientsResponseDecoder : Decoder ApiResponse
addIngredientsResponseDecoder =
    map2 ApiResponse
        (field "success" bool)
        (field "message" string)

