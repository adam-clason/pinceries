module Messages exposing (..)


import Pins.Models exposing (Pin)

import Boards.Messages
import Pins.Messages
import Groceries.Messages

type Msg
    = BoardsMsg Boards.Messages.Msg
    | PinsMsg Pins.Messages.InternalMsg
    | GroceriesMsg Groceries.Messages.Msg


translationDictionary
    = { onInternalMessage = PinsMsg 
      , onAddToGroceryList = \a -> GroceriesMsg (Groceries.Messages.AddToGroceryList a) }

