module Boards.List exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)

import Html.Attributes exposing (class, src, style, href)
import Boards.Messages exposing (..)
import Boards.Models exposing (Board)


view : List Board -> Html Msg
view boards =
    div [ class "container" ]
        [ list boards ]


list : List Board -> Html Msg
list boards =
    ul [ class "list-group" ]
        (List.map boardRow boards)


boardRow : Board -> Html Msg
boardRow board =
    li [ class "list-group-item" ]
        [ span [ class "badge" ] [ text (toString board.count) ]
        , a [ onClick (ShowPins board.id) ] [
            div [ class "media" ] 
                [ div [ class "media-left" ] [ img [ class "media-object", src board.img , style [ ("width", "60px"), ("height", "60px"), ("max-width", "none") ] ] [] ] 
                , div [ class "media-body" ] 
                    [ h4 [ class "media-heading" ] [ text board.name ]
                    , span [ ] [ text board.url ] 
                    ]
                ]
                
            ]
        ]
            


       