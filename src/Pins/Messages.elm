module Pins.Messages exposing (..)

import Http
import Pins.Models exposing (PinId, Pin)

type InternalMsg
    = FetchAllDone (List Pin)
    | FetchAllFail Http.Error

type OutMsg 
    = AddToGroceryList Pin

type Msg 
    = ForSelf InternalMsg 
    | ForParent OutMsg
