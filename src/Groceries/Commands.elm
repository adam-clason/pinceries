module Groceries.Commands exposing (..)

import Groceries.Models exposing (..)
import Groceries.Messages exposing (..)
import Json.Decode exposing (..)
import Jwt

fetchGroceryList : GroceryList -> Cmd Msg    
fetchGroceryList model  =
    Jwt.get model.jwt (fetchGroceryListUrl model) (fetchGroceryListDecoder model)
        |> Jwt.send FetchResult

fetchGroceryListUrl : GroceryList -> String
fetchGroceryListUrl model = 
    model.apiUrl ++ "/api/groceries/" ++ model.id


fetchGroceryListDecoder : GroceryList ->  Decoder GroceryList
fetchGroceryListDecoder currentModel = 
    map8 GroceryList
        (succeed currentModel.id)
        (succeed currentModel.name)
        (list ingredientDecoder)
        (succeed currentModel.count)
        (succeed currentModel.show)
        (succeed currentModel.hovering)
        (succeed currentModel.apiUrl)
        (succeed currentModel.jwt)

ingredientDecoder : Decoder Ingredient
ingredientDecoder = 
    map4 Ingredient
        (field "name" string)
        (field "amount" string)
        (field "category" string)
        (field "count" string)

saveGroceryList : GroceryList -> Cmd Msg
saveGroceryList model =
    Jwt.post model.jwt addIngredientsResponseDecoder { id = model.id, name = model.name, ingredients = model.list }

saveGroceryListUrl : GroceryList -> String 
    model.apiUrl ++ "/api/groceries/" ++ model.id


addIngredientsResponseDecoder : Decoder ApiResponse
    map2 ApiResponse
        (field "success" bool)
        (field "message" string)

