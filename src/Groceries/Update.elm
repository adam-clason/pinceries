module Groceries.Update exposing (..)

import Dict
import Groceries.Messages exposing (Msg(..))
import Groceries.Models exposing (..)
import Pins.Models exposing (Pin)

update : Msg -> GroceryList -> (GroceryList, Cmd Msg)
update message groceryList = 
    case message of 
        AddToGroceryList pin ->
            let 
                updatedGroceryList = addCategories pin groceryList

            in 
                ( updatedGroceryList, Cmd.none )

        RemoveIngredient ingredient ->
            let 
                updatedGroceryList = Dict.toList groceryList 
                    |> List.map (\(category, ingredients) -> (category, List.filter (\i -> i /= ingredient) ingredients))
                    |> Dict.fromList
            in
                ( updatedGroceryList, Cmd.none)


addCategories : Pin -> GroceryList -> GroceryList
addCategories pin groceryList =
    let 
        categories = List.map (\c -> 
                        (c.category, (List.map (\i -> Ingredient i.amount i.name ) c.ingredients))) pin.ingredients

          
    in 
        List.foldl foldCategory groceryList categories


foldCategory : (String, List Ingredient) -> GroceryList -> GroceryList
foldCategory (category, newIngredients) groceryList =
    let 
        updatedDict = Dict.update category (\value -> 
                        case value of 
                            Just ingredients ->
                                Just (List.append ingredients newIngredients)

                            Nothing ->
                                Just newIngredients
                        ) groceryList

    in 
        updatedDict
    


