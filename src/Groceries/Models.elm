module Groceries.Models exposing (..)

import Dict exposing (Dict)
import Pins.Models exposing (PinId)

type alias GroceryList 
    = Dict String (List Ingredient)


type alias Ingredient = 
    { name : String 
    , amount : String
    }