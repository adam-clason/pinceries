module Groceries.Messages exposing (..)

import Jwt exposing (JwtError)

import Pins.Models exposing (Pin)
import Groceries.Models exposing (Ingredient, GroceryList, ApiResponse)

type Msg 
    = AddToGroceryList Pin
    | RemoveIngredient Ingredient
    | FetchResult (Result JwtError GroceryList)
    | SaveResult (Result JwtError ApiResponse)
    | Show
    | HoverOut
    | Hide
