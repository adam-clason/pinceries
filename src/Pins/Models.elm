module Pins.Models exposing (..)

type alias PinId 
    = String

type alias PinsList = 
    { accessToken : String
    , boardId  : String
    , pins : List Pin
    , nextUrl : String
    }

type alias Pin =
    { id : PinId
    , url : String
    , img : String
    , note : String
    , ingredients : List Category
    }

type alias Category =
    { category : String
    , ingredients : List Ingredient
    } 

type alias Ingredient = 
    { amount : String  
    , name : String
    }