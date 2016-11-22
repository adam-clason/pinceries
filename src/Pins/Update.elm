module Pins.Update exposing (..)

import Navigation
import Pins.Messages exposing (InternalMsg(..), Msg(..), OutMsg(..))
import Groceries.Messages
import Pins.Models exposing (Pin)



type alias Translator parentMsg = Msg -> parentMsg

type alias TranslationDictionary msg =
  { onInternalMessage: InternalMsg -> msg
  , onAddToGroceryList: Pin -> msg
  }


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onAddToGroceryList } msg =
    case msg of 
        ForSelf internal ->
            onInternalMessage internal 

        ForParent (AddToGroceryList pin) ->
            onAddToGroceryList pin 


update : InternalMsg -> List Pin -> ( List Pin, Cmd Msg )
update message pins =
    case message of
        FetchAllDone newPins ->
            ( newPins, Cmd.none )

        FetchAllFail error ->
            ( pins, Cmd.none )