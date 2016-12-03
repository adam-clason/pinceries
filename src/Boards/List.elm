module Boards.List exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)

import Html.Attributes exposing (class, src, style, href)
import Boards.Messages exposing (..)
import Boards.Models exposing (Board)


view : List Board -> Html Msg
view boards =
    div [ class "container" ]
        [ h1 [ class "columns" ] 
            [ span [] [ text "Boards " ]
            , small [] [ text "Select a board"]
            ] 
        , 

        list boards ]


list : List Board -> Html Msg
list boards =
    div [ class "row small-up-2 medium-up-3 larg-up-4" ]
        (List.map boardRow boards)


boardRow : Board -> Html Msg
boardRow board =
    div [ class "column" ]
        [ a [ class "board", onClick (ShowPins board.id) ]
            [ div [ ]
                [ div [ class "board-img" ] [ img [ src board.img ] [] ] ]
            , div [ ]
                [ h4 [ ] [ text board.name ]     
                ]
            ]
        ]            


       