module Groceries.Models exposing (..)

import Dict exposing (Dict)
import Pins.Models exposing (PinId)

type alias IngredientsList 
    = List Ingredient

type alias GroceryList =
    { id : String
    , name : String
    , list : IngredientsList
    , count : Int
    , show : Bool
    , hovering : Bool  
    , apiUrl : String
    , jwt : String
    }

type alias Ingredient = 
    { name : String 
    , amount : String
    , category : String
    , count : Int
    , pinId : String
    }

type alias ApiResponse = 
    { success : Bool    
    , message : String 
    }