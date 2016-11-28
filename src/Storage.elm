port module Storage exposing(..)

import Messages exposing (Msg(..))

port setAccessToken : String -> Cmd msg

port setJwt : String -> Cmd msg


