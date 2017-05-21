module Pins.Messages exposing (..)

import Http
import Pins.Models exposing (PinsList)
import Pinterest.Models exposing (Pin)


type InternalMsg
    = FetchAllDone (Result Http.Error PinsList)
    | NextPage String

type OutMsg 
    = AddToGroceryList Pin
    | RemoveFromGroceryList Pin
    | PinterestApiError

type Msg 
    = ForSelf InternalMsg 
    | ForParent OutMsg
