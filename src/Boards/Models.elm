module Boards.Models exposing (..)


type alias BoardId =
    String


type alias Board =
    { id : BoardId
    , url : String
    , name : String
    , count : Int
    , img : String
    }


new : Board
new =
    { id = ""
    , url = ""
    , name = ""
    , count = 0
    , img = ""
    }