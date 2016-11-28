module Models exposing (..)

import Boards.Models exposing (Board)
import Pins.Models exposing (Pin)
import Groceries.Models exposing (..)
import Routing
import Dict

type alias Model =
    { accessToken : String
    , jwt : String
    , boards : List Board
    , pins : List Pin
    , groceryList : GroceryList
    , route : Routing.Route
    }

type alias Flags =
    { accessToken : String
    , jwt : String
    }

initialModel : Flags -> Routing.Route -> Model
initialModel flags route =
    { accessToken = flags.accessToken
    , jwt = flags.jwt
    , boards = []
    , pins = [] 
    , groceryList = GroceryList Dict.empty 0 False False
    , route = route
    }
