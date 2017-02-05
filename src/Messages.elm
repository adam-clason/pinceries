module Messages exposing (..)

import Http
import Models exposing (AuthorizeInfo)
import Pins.Models exposing (Pin)
import Navigation
import Boards.Messages
import Pins.Messages
import Groceries.Messages
import Alerts.Messages  

type Msg
    = BoardsMsg Boards.Messages.Msg
    | PinsMsg Pins.Messages.InternalMsg
    | GroceriesMsg Groceries.Messages.InternalMsg
    | AlertsMsg Alerts.Messages.Msg
    | UrlChange Navigation.Location
    | Authorized (Result Http.Error AuthorizeInfo)
    | AuthorizationError


pinsTranslationDictionary
    = { onInternalMessage = PinsMsg 
      , onAddToGroceryList = \a -> GroceriesMsg (Groceries.Messages.AddToGroceryList a) 
      , onRemoveFromGroceryList = \a -> GroceriesMsg (Groceries.Messages.RemoveFromGroceryList a) }

groceriesTranslationDictionary
    = { onInternalMessage = GroceriesMsg
      , onAuthError = AuthorizationError }