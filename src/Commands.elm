module Commands exposing (..)

import Http
import Json.Decode exposing (..)
import Task
import Pins.Models exposing (PinId, Pin, Category, Ingredient)
import Boards.Models exposing (BoardId, Board)
import Messages exposing (Msg(..))


fetchAccessToken : String -> Cmd Msg
fetchAccessToken authCode =
    Http.post fetchAccessTokenUrl (fetchAccessTokenBody authCode) accessTokenDecoder 
        |> Http.send AuthorizeDone

fetchAccessTokenUrl =
    "https://api.pinterest.com/v1/oauth/token"

fetchAccessTokenBody : String -> Http.Body
fetchAccessTokenBody authCode =
    Http.stringBody "application/x-www-form-urlencoded" ("grant_type=authorization_code&client_id=4869854870047304425&client_secret=8c6a41e11b9c6594d5d52da8c98c929fb9a43c6c23197a7a20792d3118454f7c&code=" ++ authCode) 

accessTokenDecoder : Decoder String
accessTokenDecoder =
    field "access_token" string