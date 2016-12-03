module Messages exposing (..)

import Http
import Models exposing (AuthorizeInfo)
import Pins.Models exposing (Pin)
import Navigation
import Boards.Messages
import Pins.Messages
import Groceries.Messages

type Msg
    = BoardsMsg Boards.Messages.Msg
    | PinsMsg Pins.Messages.InternalMsg
    | GroceriesMsg Groceries.Messages.Msg
    | UrlChange Navigation.Location
    | Authorized (Result Http.Error AuthorizeInfo)


translationDictionary
    = { onInternalMessage = PinsMsg 
      , onAddToGroceryList = \a -> GroceriesMsg (Groceries.Messages.AddToGroceryList a) }

