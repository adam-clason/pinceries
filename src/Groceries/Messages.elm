module Groceries.Messages exposing (..)

import Jwt exposing (JwtError)

import Pins.Models exposing (Pin)
import Groceries.Models exposing (Ingredient, GroceryList)

type Msg 
    = AddToGroceryList Pin
    | RemoveIngredient Ingredient
    | FetchResult (Result JwtError GroceryList)
    | Show
    | HoverOut
    | Hide
