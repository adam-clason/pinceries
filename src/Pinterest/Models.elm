module Pinterest.Models exposing (..)

type alias Pin =
    { id : String
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
    { pinId : String
    , amount : String  
    , name : String
    }