module Commands exposing (..)

import Jwt exposing (decodeToken, JwtError)
import Http
import Json.Decode exposing (..)
import Task exposing (Task)
import Pins.Models exposing (PinId, Pin, Category, Ingredient)
import Boards.Models exposing (BoardId, Board)
import Messages exposing (Msg(..))
import Models exposing (Model, AuthorizeInfo, User)
    
fetchAccessToken : Model -> String -> Task Http.Error String
fetchAccessToken model authCode =
    Http.post fetchAccessTokenUrl (fetchAccessTokenBody authCode) accessTokenDecoder 
        |> Http.toTask

fetchAccessTokenUrl =
    "https://api.pinterest.com/v1/oauth/token"

fetchAccessTokenBody : String -> Http.Body
fetchAccessTokenBody authCode =
    Http.stringBody "application/x-www-form-urlencoded" ("grant_type=authorization_code&client_id=4869855014851457651&client_secret=a27b2684e0d64199dc3f634894ee0fb687b04a3ca9ad5f6fb67fce91255cf42d&code=" ++ authCode) 

accessTokenDecoder : Decoder String
accessTokenDecoder =
    field "access_token" string


fetchPinceriesApiJwt : Model -> String -> Task Http.Error AuthorizeInfo
fetchPinceriesApiJwt model accessToken =
    Http.post (fetchPinceriesApiJwtUrl model.pinceriesApiBaseUrl) (fetchPinceriesApiJwtBody accessToken) (fetchPinceriesApiJwtDecoder accessToken)
        |> Http.toTask


fetchPinceriesApiJwtUrl : String -> String
fetchPinceriesApiJwtUrl baseUrl = 
    baseUrl ++ "/api/authenticate"

fetchPinceriesApiJwtBody : String -> Http.Body
fetchPinceriesApiJwtBody accessToken = 
    Http.stringBody "application/x-www-form-urlencoded" ("token=" ++ accessToken) 

fetchPinceriesApiJwtDecoder : String ->  Decoder AuthorizeInfo
fetchPinceriesApiJwtDecoder accessToken = 
    map2 AuthorizeInfo
        (succeed accessToken)
        (field "jwt" string)


decodeJwt : String -> Result JwtError User
decodeJwt jwt =

    let 
        jwtDecoder = 
            map4 User
                (field "id" string)
                (field "firstName" string)
                (field "lastName" string)
                (field "activeGroceryListId" string)

    in 
        decodeToken jwtDecoder jwt


