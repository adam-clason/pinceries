module Messages exposing (..)

import Http
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
    | AuthorizeDone (Result Http.Error String)


translationDictionary
    = { onInternalMessage = PinsMsg 
      , onAddToGroceryList = \a -> GroceriesMsg (Groceries.Messages.AddToGroceryList a) }

