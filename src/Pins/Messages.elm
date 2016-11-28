module Pins.Messages exposing (..)

import Http
import Pins.Models exposing (PinId, Pin)

type alias PinsList = List Pin

type InternalMsg
    = FetchAllDone (Result Http.Error PinsList)

type OutMsg 
    = AddToGroceryList Pin

type Msg 
    = ForSelf InternalMsg 
    | ForParent OutMsg
