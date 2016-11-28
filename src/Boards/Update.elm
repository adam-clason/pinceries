module Boards.Update exposing (..)

import Navigation
import Boards.Messages exposing (Msg(..))
import Boards.Models exposing (Board)


update : Msg -> List Board -> ( List Board, Cmd Msg )
update message boards =
    case message of
        FetchAllDone (Ok newBoards) ->
            ( newBoards, Cmd.none )

        FetchAllDone (Err _) ->
            ( boards, Cmd.none)

        ShowPins boardId ->
            ( boards, Navigation.newUrl ("#boards/" ++ boardId) )