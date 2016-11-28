module Routing exposing (..)

import Debug
import String
import Navigation
import UrlParser exposing (..)

import Boards.Models exposing (BoardId)


type InnerRoute
    = BoardsRoute
    | BoardRoute BoardId
    | Authorize (Maybe String)


type Route 
    = Authenticated InnerRoute
    | Anonymous InnerRoute
    | NotFoundRoute


pathMatchers : Parser (Route -> a) a
pathMatchers = 
    oneOf 
        [ map (\ac -> Anonymous (Authorize ac)) (s "authorize" <?> stringParam "code")
        ] 


hashMatchers : Parser (Route -> a) a
hashMatchers =
    oneOf
        [ map (Authenticated BoardsRoute) (s "")
        , map (\b -> Authenticated (BoardRoute b)) (s "boards" </> string)
        , map (Authenticated BoardsRoute) (s "boards")
        ]

urlParser : Navigation.Location -> Maybe Route
urlParser location = 
    if not (String.isEmpty location.hash) then 
        location |> parseHash hashMatchers
    else 
        location |> parsePath pathMatchers
       
  

parser : Navigation.Location -> Maybe Route
parser location =
    urlParser location


routeFromMaybe : Maybe Route -> Route
routeFromMaybe maybe =
    case maybe of
        Just route ->
            route

        Nothing ->
            NotFoundRoute