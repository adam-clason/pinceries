module Boards.Messages exposing (..)

import Http
import Boards.Models exposing (BoardId, Board)

type alias BoardList = List Board

type Msg
    = FetchAllDone (Result Http.Error BoardList)
    | ShowPins BoardId