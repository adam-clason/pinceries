module Groceries.Models exposing (..)

import Dict exposing (Dict)
import Pinterest.Models exposing (Pin)

type alias PinsDict 
    = Dict String Pin

type ArrangeBy = Category | Pin

type alias GroceryList =
    { id : String
    , name : String
    , list : List Ingredient
    , pins : PinsDict
    , arrangeBy : ArrangeBy  
    , apiUrl : String
    , jwt : String
    , accessToken : String
    }

type alias Ingredient = 
    { id : String
    , name : String 
    , amount : String
    , category : String
    , count : Int
    , pinId : String
    , checked : Bool
    }

type alias ApiResponse = 
    { success : Bool    
    , message : String 
    }