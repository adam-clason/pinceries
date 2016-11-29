module Boards.Commands exposing (..)

import Http
import Json.Decode as Decode exposing (..)
import Task
import Models exposing (Model)
import Boards.Models exposing (BoardId, Board)
import Boards.Messages exposing (..)


fetchAll : Model -> Cmd Msg
fetchAll model =
    Http.get (fetchAllUrl model.accessToken) collectionDecoder 
        |> Http.send FetchAllDone


fetchAllUrl : String -> String
fetchAllUrl accessToken =
    "https://api.pinterest.com/v1/me/boards/?access_token=" ++ accessToken ++ "&fields=id%2Cname%2Curl%2Ccounts%2Cimage"


collectionDecoder : Decoder (List Board)
collectionDecoder =
    at ["data"] (list memberDecoder)


memberDecoder : Decoder Board
memberDecoder =
    map5 Board
        (field "id" string)
        (field "url" string)
        (field "name" string)
        (at ["counts"] (field "pins" int))
        (at ["image", "60x60"] (field "url" string))
  