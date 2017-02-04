module Alerts.View exposing (..)

import Alerts.Models exposing (AlertsList, Alert)
import Alerts.Messages exposing (..)

import Html exposing (Html, div, text, i, span)

import Html.Attributes exposing (attribute, class)


view : AlertsList -> Html Msg
view alerts =
    div [ class "container" ] (List.map alert alerts)
    

alert : Alert -> Html Msg 
alert alert = 
    div [ attribute "data-alert" "", class "row alert-box alert" ]
        [ div [ class "columns" ] 
            [ i [ class "fa fa-warning" ] []
            , span [] [ text alert.message ]
            ]
        ]