port module Pins.Update exposing (..)

import Http
import Navigation
import Cmd.Extra
import Pins.Commands exposing (fetchPins)
import Pins.Messages exposing (InternalMsg(..), Msg(..), OutMsg(..))
import Groceries.Messages
import Pins.Models exposing (..)
import Pinterest.Models exposing (Pin)

type alias Translator parentMsg = Msg -> parentMsg

type alias TranslationDictionary msg =
  { onInternalMessage: InternalMsg -> msg
  , onAddToGroceryList: Pin -> msg
  , onRemoveFromGroceryList: Pin -> msg
  , onPinterestApiError: msg
  }


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onAddToGroceryList, onRemoveFromGroceryList, onPinterestApiError } msg =
    case msg of 
        ForSelf internal ->
            onInternalMessage internal 

        ForParent (AddToGroceryList pin) ->
            onAddToGroceryList pin 

        ForParent (RemoveFromGroceryList pin) ->
            onRemoveFromGroceryList pin

        ForParent (PinterestApiError) -> 
            onPinterestApiError


update : InternalMsg -> PinsList -> ( PinsList, Cmd Msg )
update message pinsList =
    case message of
        FetchAllDone (Ok newPinsList) ->
            let 
                updatedPinsList =
                    { pinsList | nextUrl = newPinsList.nextUrl, pins = List.concat [ pinsList.pins, newPinsList.pins] } 
            in
                ( updatedPinsList, pageLoaded "" )

        FetchAllDone (Err  _) ->
            ( pinsList, Cmd.Extra.message (ForParent PinterestApiError) )

        NextPage cursor -> 
            ( pinsList, fetchPins pinsList cursor )


port nextPage : (String -> msg) -> Sub msg
port pageLoaded : String -> Cmd msg

subscriptions : Sub Msg 
subscriptions = 
  nextPage (\msg -> ForSelf (NextPage msg))