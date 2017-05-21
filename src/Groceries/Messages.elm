module Groceries.Messages exposing (..)

import Jwt exposing (JwtError)
import Http

import Pinterest.Models exposing (Pin)
import Groceries.Models exposing (Ingredient, ArrangeBy, ApiResponse, GroceryList)

type InternalMsg 
    = AddToGroceryList Pin
    | RemoveFromGroceryList Pin
    | RemoveIngredient Ingredient
    | ShowGroceryList
    | SwitchTo ArrangeBy
    | FetchResult (Result JwtError GroceryList)
    | SaveResult (Result JwtError ApiResponse)
    | PinRetrievedResult (Result Http.Error Pin)

type OutMsg 
    = AuthorizationError

type Msg 
    = ForSelf InternalMsg
    | ForParent OutMsg
