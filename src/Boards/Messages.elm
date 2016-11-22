module Boards.Messages exposing (..)

import Http
import Boards.Models exposing (BoardId, Board)


type Msg
    = FetchAllDone (List Board)
    | FetchAllFail Http.Error
    | ShowPins BoardId