module Alerts.Update exposing (..)


import Alerts.Messages exposing (Msg(..))
import Alerts.Models exposing (AlertsList, Alert )

update : Msg -> AlertsList -> (AlertsList, Cmd Msg)
update message alerts =
    case message of
        AuthorizationError ->
            let updatedAlerts =
                (Alert "There was an error authorizing your account. Please re-authorize your account with Pinterest") :: alerts
            in 
                (updatedAlerts, Cmd.none)

        PinterestApiError -> 
            let updatedAlerts =
                (Alert "There was an error with the Pinterest API. Please try again later") :: alerts
            in 
                (updatedAlerts, Cmd.none)

        ClearAlerts ->
            ([], Cmd.none)
