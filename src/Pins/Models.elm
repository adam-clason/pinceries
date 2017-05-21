module Pins.Models exposing (..)

import Pinterest.Models exposing (Pin)

type alias PinsList = 
    { accessToken : String
    , boardId  : String
    , pins : List Pin
    , nextUrl : String
    }

