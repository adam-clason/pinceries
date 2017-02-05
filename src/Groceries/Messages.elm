module Groceries.Messages exposing (..)

import Jwt exposing (JwtError)

import Pins.Models exposing (Pin)
import Groceries.Models exposing (Ingredient, GroceryList, ApiResponse)

type InternalMsg 
    = AddToGroceryList Pin
    | RemoveFromGroceryList Pin
    | RemoveIngredient Ingredient
    | FetchResult (Result JwtError GroceryList)
    | SaveResult (Result JwtError ApiResponse)

type OutMsg 
    = AuthorizationError

type Msg 
    = ForSelf InternalMsg
    | ForParent OutMsg
