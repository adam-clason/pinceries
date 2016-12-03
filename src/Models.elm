module Models exposing (..)

import Boards.Models exposing (Board)
import Pins.Models exposing (Pin)
import Groceries.Models exposing (..)
import Routing
import Dict


type alias User = 
    { id : String
    , firstName : String
    , lastName : String
    , activeGroceryListId : String
    }

type alias Model =
    { accessToken : String
    , jwt : String
    , user : User
    , boards : List Board
    , pins : List Pin
    , groceryList : GroceryList
    , route : Routing.Route
    , pinceriesApiBaseUrl : String
    , pinterestRedirectUrl : String
    }

type alias Flags =
    { accessToken : String
    , jwt : String
    , pinceriesApiBaseUrl : String
    , pinterestRedirectUrl : String
    }

type alias AuthorizeInfo =
    { accessToken : String
    , jwt : String 
    }

initialModel : Flags -> Routing.Route -> Model
initialModel flags route =
    { accessToken = flags.accessToken
    , jwt = flags.jwt
    , user = User "" "" "" ""
    , pinceriesApiBaseUrl = flags.pinceriesApiBaseUrl
    , pinterestRedirectUrl = flags.pinterestRedirectUrl
    , boards = []
    , pins = [] 
    , groceryList = GroceryList "" "" Dict.empty 0 False False flags.pinceriesApiBaseUrl
    , route = route
    }
