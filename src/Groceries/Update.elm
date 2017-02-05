port module Groceries.Update exposing (..)

import Process
import Task exposing (Task)
import Basics exposing (Never)
import Time
import Navigation
import Storage
import Http exposing (Error(..))
import Jwt exposing (JwtError(..))
import Cmd.Extra 
import Groceries.Messages exposing (InternalMsg(..), OutMsg(..), Msg(..))
import Groceries.Models exposing (..)
import Groceries.Commands exposing (saveGroceryList)
import Pins.Models exposing (Pin)


type alias Translator parentMsg = Msg -> parentMsg

type alias TranslationDictionary msg =
  { onInternalMessage: InternalMsg -> msg
  , onAuthError: msg
  }


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onAuthError } msg =
    case msg of 
        ForSelf internal ->
            onInternalMessage internal 

        ForParent AuthorizationError ->
            onAuthError 



update : InternalMsg -> GroceryList -> (GroceryList, Cmd Msg)
update message groceryList = 
    case message of 
        AddToGroceryList pin ->
            let 
                updatedIngredientsList = 
                    addIngredients pin groceryList.list
                updatedCount = 
                    List.length updatedIngredientsList
                updatedModel =
                    { groceryList | list = updatedIngredientsList, count = updatedCount }

            in 
                ( updatedModel, Cmd.batch [ showSlideout "", saveGroceryList updatedModel ])

        RemoveFromGroceryList pin ->
            let
                updatedIngredientsList = 
                    removeIngredients pin groceryList.list
                updatedModel =
                    { groceryList | list = updatedIngredientsList }

            in
                ( updatedModel, saveGroceryList updatedModel )

        RemoveIngredient ingredient ->
            let 
                updatedIngredientsList = 
                    List.filter (\i -> (i.name /= ingredient.name) ||  (i.amount /= ingredient.amount))  groceryList.list
                updatedModel = 
                    { groceryList | list = updatedIngredientsList }

            in
                ( updatedModel , saveGroceryList updatedModel)

        FetchResult result ->
            case result of 
                Ok updatedModel ->
                    (updatedModel, initSlideout "")

                Err error ->

                    let 
                        authErrorCommands =
                            [ Storage.setAccessToken ""
                            , Storage.setJwt ""
                            , Cmd.Extra.message (ForParent AuthorizationError)
                            , Navigation.newUrl "/"
                            ] 
                    in 
                        case error of 
                            Unauthorized -> 
                                (groceryList, Cmd.batch authErrorCommands)

                            HttpError httpError ->
                                case httpError of 
                                    Timeout -> 
                                        (groceryList, Cmd.none)

                                    BadStatus response ->       
                                        (groceryList, Cmd.batch authErrorCommands)
                                    
                                    _ ->
                                        (groceryList, Cmd.none)
                            _ ->
                                (groceryList, Cmd.none)

        SaveResult _ -> 
            ( groceryList, Cmd.none )


addIngredients : Pin -> IngredientsList -> IngredientsList
addIngredients pin ingredientsList =
    let 
        addedIngredients = 
            List.concatMap (\c -> 
                    (List.map (\i -> Ingredient i.amount i.name c.category 1 pin.id ) c.ingredients)) pin.ingredients

          
    in 
        List.foldl foldAddIngredients ingredientsList addedIngredients

removeIngredients : Pin -> IngredientsList -> IngredientsList
removeIngredients pin ingredientsList =
    let 
        updatedIngredientsList = 
            List.filter (\i -> i.pinId /= pin.id) ingredientsList
    in 
        updatedIngredientsList


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


port initSlideout : String -> Cmd msg 
port showSlideout : String -> Cmd msg

delayHideList : msg -> Cmd msg
delayHideList msg =
    Process.sleep (Time.second * 3)
    |> Task.andThen (always <| Task.succeed msg)
    |> Task.perform identity


never : Never -> a
never n = never n





