module Models exposing (..)

import Boards.Models exposing (Board)
import Pins.Models exposing (Pin)
import Groceries.Models exposing (..)
import Routing
import Dict

type alias Model =
    { boards : List Board
    , pins : List Pin
    , groceryList : GroceryList
    , route : Routing.Route
    }


initialModel : Routing.Route -> Model
initialModel route =
    { boards = []
    , pins = [] 
    , groceryList = GroceryList Dict.empty 0 False False
    , route = route
    }
