module Pins.Messages exposing (..)

import Http
import Pins.Models exposing (PinsList, PinId, Pin)


type InternalMsg
    = FetchAllDone (Result Http.Error PinsList)
    | NextPage String

type OutMsg 
    = AddToGroceryList Pin
    | RemoveFromGroceryList Pin

type Msg 
    = ForSelf InternalMsg 
    | ForParent OutMsg
