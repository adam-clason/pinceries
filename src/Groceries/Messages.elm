module Groceries.Messages exposing (..)

import Pins.Models exposing (Pin)
import Groceries.Models exposing (Ingredient)

type Msg 
    = AddToGroceryList Pin
    | RemoveIngredient Ingredient
    | Show
    | HoverOut
    | Hide
