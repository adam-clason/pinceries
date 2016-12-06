port module Groceries.Update exposing (..)

import Process
import Task exposing (Task)
import Basics exposing (Never)
import Time
import Dict
import Groceries.Messages exposing (Msg(..))
import Groceries.Models exposing (..)
import Pins.Models exposing (Pin)

update : Msg -> GroceryList -> (GroceryList, Cmd Msg)
update message groceryList = 
    case message of 
        AddToGroceryList pin ->
            let 
                updatedIngredientsList = 
                    addIngredients pin groceryList.list
                updatedCount = 
                    List.length updatedIngredientsList

            in 
                ( { groceryList | list = updatedIngredientsList, show = True, count = updatedCount }, delayHideList Hide )

        RemoveIngredient ingredient ->
            let 
                updatedIngredientsList = 
                    List.filter (\i -> (i.name /= ingredient.name) ||  (i.amount /= ingredient.amount))  groceryList.list

            in
                ( { groceryList | list = updatedIngredientsList,  show = True }, Cmd.none)

        FetchResult _ ->
            (groceryList, Cmd.none )

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


addIngredients : Pin -> IngredientsList -> IngredientsList
addIngredients pin ingredientsList =
    let 
        addedIngredients = 
            List.concatMap (\c -> 
                    (List.map (\i -> Ingredient i.amount i.name c.category 1 ) c.ingredients)) pin.ingredients

          
    in 
        List.foldl foldAddIngredients ingredientsList addedIngredients


foldAddIngredients : Ingredient -> IngredientsList -> IngredientsList
foldAddIngredients addedIngredient ingredientsList =
    let 
        ingredientInList = 
            (\i -> i.name == addedIngredient.name && i.amount == addedIngredient.amount)
        ingredientIsInList =
            List.any ingredientInList ingredientsList
    in 
        if ingredientIsInList then
            List.map 
                (\i -> 
                    if i.name == addedIngredient.name && i.amount == addedIngredient.amount then
                        { i | count = i.count + 1 }
                    else 
                        i
                ) ingredientsList
        else 
            addedIngredient :: ingredientsList


delayHideList : msg -> Cmd msg
delayHideList msg =
    Process.sleep (Time.second * 3)
    |> Task.andThen (always <| Task.succeed msg)
    |> Task.perform identity

never : Never -> a
never n = never n






