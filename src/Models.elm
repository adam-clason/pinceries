module Models exposing (..)

import Boards.Models exposing (Board)
import Alerts.Models exposing (AlertsList)
import Pins.Models exposing (PinsList)
import Groceries.Models exposing (..)
import Pinterest.Commands exposing (..)
import Jwt exposing (decodeToken, JwtError)
import Json.Decode exposing (..)
import Routing
import Dict



type alias User = 
    { id : String
    , firstName : String
    , lastName : String
    , activeGroceryListId : String
    }

type alias Model =
    { accessToken : String
    , jwt : String
    , alerts : AlertsList
    , user : User
    , boards : List Board
    , pinsList : PinsList
    , groceryList : GroceryList
    , route : Routing.Route
    , pinceriesApiBaseUrl : String
    , pinterestRedirectUrl : String
    }

type alias Flags =
    { accessToken : String
    , jwt : String
    , pinceriesApiBaseUrl : String
    , pinterestRedirectUrl : String
    }

type alias AuthorizeInfo =
    { accessToken : String
    , jwt : String 
    }

initialModel : Flags -> Routing.Route -> Model
initialModel flags route =
    let 
        initUser = 
            userFromJwt flags.jwt |> userFromResult

    in 
        { accessToken = flags.accessToken
        , jwt = flags.jwt
        , alerts = []
        , user = initUser
        , pinceriesApiBaseUrl = flags.pinceriesApiBaseUrl
        , pinterestRedirectUrl = flags.pinterestRedirectUrl
        , boards = []
        , pinsList = PinsList flags.accessToken "" [] ""
        , groceryList = GroceryList initUser.activeGroceryListId "" [] Dict.empty Category flags.pinceriesApiBaseUrl flags.jwt flags.accessToken 
        , route = route
        }


userFromResult : Result JwtError User -> User
userFromResult result =
    case result of 
        Ok user ->
            user

        Err _ ->
            User "" "" "" ""

userFromJwt : String -> Result JwtError User
userFromJwt jwt =
    let 
        jwtDecoder = 
            map4 User
                (field "id" string)
                (field "firstName" string)
                (field "lastName" string)
                (field "activeGroceryListId" string)

    in 
        Jwt.decodeToken jwtDecoder jwt
