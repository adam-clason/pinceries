module Groceries.Models exposing (..)

import Dict exposing (Dict)
import Pins.Models exposing (PinId)

type alias IngredientsList 
    =  Dict String (List Ingredient)

type alias GroceryList =
    { list : IngredientsList
    , count : Int
    , show : Bool
    , hovering : Bool  
    }

type alias Ingredient = 
    { name : String 
    , amount : String
    }