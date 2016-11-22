module Boards.Commands exposing (..)

import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Boards.Models exposing (BoardId, Board)
import Boards.Messages exposing (..)


fetchAll : Cmd Msg
fetchAll =
    Http.get collectionDecoder fetchAllUrl
        |> Task.perform FetchAllFail FetchAllDone


fetchAllUrl : String
fetchAllUrl =
    "https://api.pinterest.com/v1/me/boards/?access_token=AQd4ETHUsMnngL1fpWPuzWCPO7YHFIcZHbDSiYpDjk-3wcA37wAAAAA&fields=id%2Cname%2Curl%2Ccounts%2Cimage"


collectionDecoder : Decode.Decoder (List Board)
collectionDecoder =
    Decode.at ["data"] (Decode.list memberDecoder)


memberDecoder : Decode.Decoder Board
memberDecoder =
    Decode.object5 Board
        ("id" := Decode.string)
        ("url" := Decode.string)
        ("name" := Decode.string)
        (Decode.at ["counts"] ("pins" := Decode.int))
        (Decode.at ["image", "60x60"] ("url" := Decode.string))
  