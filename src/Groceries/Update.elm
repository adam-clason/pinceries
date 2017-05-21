port module Groceries.Update exposing (..)

import Process
import Dict
import Set
import Task exposing (Task)
import Basics exposing (Never)
import Time
import Navigation
import Storage
import Http exposing (Error(..))
import Jwt exposing (JwtError(..))
import Cmd.Extra 
import Util.Functions exposing (snd)
import Groceries.Messages exposing (InternalMsg(..), OutMsg(..), Msg(..))
import Groceries.Models exposing (..)
import Groceries.Commands exposing (saveGroceryList)
import Pinterest.Models exposing (Pin)
import Pinterest.Commands exposing (..)

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
                    { groceryList | list = updatedIngredientsList }

            in 
                ( updatedModel, Cmd.batch [ groceryListChanged, saveGroceryList updatedModel ])

        RemoveFromGroceryList pin ->
            let
                updatedIngredientsList = 
                    removeIngredients pin groceryList.list
                updatedModel =
                    { groceryList | list = updatedIngredientsList }

            in
                ( updatedModel, Cmd.batch [ groceryListChanged, saveGroceryList updatedModel ] )

        RemoveIngredient ingredient ->
            let 
                updatedIngredientsList = 
                    List.filter (\i -> (i.name /= ingredient.name) ||  (i.amount /= ingredient.amount))  groceryList.list
                updatedModel = 
                    { groceryList | list = updatedIngredientsList }

            in
                ( updatedModel, saveGroceryList updatedModel)

        PinRetrievedResult result -> 
            case result of 
                Ok pin -> 
                     let 
                        updatedPinList = 
                            Dict.update pin.id (\p -> Just pin) groceryList.pins
                        updatedModel =  
                            { groceryList | pins = updatedPinList }
                    in
                        (updatedModel, Cmd.none)

                Err error ->
                    (groceryList, Cmd.none)

        ShowGroceryList -> 
            ( groceryList, Cmd.batch [ Navigation.newUrl "/#groceries", closeSlideout ] )

        SwitchTo updatedArrangeBy ->
            ( { groceryList | arrangeBy = updatedArrangeBy }, Cmd.none)

        FetchResult result ->
            case result of 
                Ok updatedModel ->
                    let 
                        step next (set, acc) = 
                            if Set.member next.pinId set
                                then (set, acc)
                                else (Set.insert next.pinId set, next.pinId :: acc)
                        uniquePins =
                            List.foldl step (Set.empty, []) updatedModel.list |> snd
                        fetchPinsCmd = 
                            fetchPinsForIngredients groceryList.accessToken (\msg -> ForSelf (PinRetrievedResult msg)) uniquePins
                    in
                        (updatedModel, Cmd.batch [ initSlideout, fetchPinsCmd ])

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


addIngredients : Pin -> List Ingredient -> List Ingredient
addIngredients pin ingredientsList =
    let 
        addedIngredients = 
            List.concatMap (\c -> 
                    (List.map (\i -> Ingredient "" i.name i.amount c.category 1 pin.id False) c.ingredients)) pin.ingredients

    in 
        List.foldl foldAddIngredients ingredientsList addedIngredients

removeIngredients : Pin -> List Ingredient -> List Ingredient
removeIngredients pin ingredientsList =
    let 
        updatedIngredientsList = 
            List.filter (\i -> i.pinId /= pin.id) ingredientsList
    in 
        updatedIngredientsList


foldAddIngredients : Ingredient -> List Ingredient -> List Ingredient
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


groceryListChanged: Cmd msg 
groceryListChanged =
    groceryListChangedPort "" 

initSlideout: Cmd msg 
initSlideout =
    initSlideoutPort ""

closeSlideout: Cmd msg 
closeSlideout = 
    closeSlideoutPort ""

port initSlideoutPort: String -> Cmd msg 
port closeSlideoutPort: String -> Cmd msg
port groceryListChangedPort : String -> Cmd msg 

delayHideList : msg -> Cmd msg
delayHideList msg =
    Process.sleep (Time.second * 3)
    |> Task.andThen (always <| Task.succeed msg)
    |> Task.perform identity


never : Never -> a
never n = never n





