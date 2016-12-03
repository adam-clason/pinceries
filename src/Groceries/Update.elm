port module Groceries.Update exposing (..)

import Process
import Task exposing (Task)
import Basics exposing (Never)
import Time
import Dict
import Groceries.Messages exposing (Msg(..))
import Groceries.Models exposing (..)
import Groceries.Commands exposing (saveGroceryList)
import Pins.Models exposing (Pin)

update : Msg -> GroceryList -> (GroceryList, Cmd Msg)
update message groceryList = 
    case message of 
        AddToGroceryList pin ->
            let 
                updatedIngredientsList 
                    = addCategories pin groceryList.list
                updatedCount 
                    = ingredientCount updatedIngredientsList

            in 
                ( { groceryList | list = updatedIngredientsList, show = True, count = updatedCount }, delayHideList Hide )

        RemoveIngredient ingredient ->
            let 
                updatedIngredientsList = Dict.toList groceryList.list
                    |> List.map (\(category, ingredients) -> (category, List.filter (\i -> i /= ingredient) ingredients))
                    |> Dict.fromList
            in
                ( { groceryList | list = updatedIngredientsList,  show = True }, Cmd.none)

        Show -> 
            ( { groceryList | show = True, hovering = True }, Cmd.none)

        HoverOut ->
            ( { groceryList | show = False }, Cmd.none)

        Hide -> 
            let hideList 
                = case groceryList.hovering of 
                    True -> False
                    False -> True
            in
                ( { groceryList | show = not hideList }, Cmd.none)

        Name updatedName ->
            ( { groceryList | name = updatedName }, Cmd.none )

        Save -> 
            ( groceryList, saveGroceryList groceryList)


addCategories : Pin -> IngredientsList -> IngredientsList
addCategories pin ingredientsList =
    let 
        categories = List.map (\c -> 
                        (c.category, (List.map (\i -> Ingredient i.amount i.name ) c.ingredients))) pin.ingredients

          
    in 
        List.foldl foldCategory ingredientsList categories


foldCategory : (String, List Ingredient) -> IngredientsList -> IngredientsList
foldCategory (category, newIngredients) ingredientsList =
    let 
        updatedDict = Dict.update category (\value -> 
                        case value of 
                            Just ingredients ->
                                Just (List.append ingredients newIngredients)

                            Nothing ->
                                Just newIngredients
                        ) ingredientsList

    in 
        updatedDict
    
ingredientCount : IngredientsList -> Int
ingredientCount ingredientsList =
    Dict.toList ingredientsList
        |> List.map (\(category, ingredients) -> ingredients)
        |> List.concat
        |> List.length



delayHideList : msg -> Cmd msg
delayHideList msg =
    Process.sleep (Time.second * 3)
    |> Task.andThen (always <| Task.succeed msg)
    |> Task.perform identity

never : Never -> a
never n = never n






