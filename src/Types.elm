module Types exposing (..)

import Bridge
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Main as ElmLand
import Url exposing (Url)
import Api.User exposing (User, Email)
import Dict exposing (Dict)

type alias FrontendModel =
    ElmLand.Model


type alias BackendModel =
    { smashedLikes : Int
    , users : Dict Email User
    }


type alias FrontendMsg =
    ElmLand.Msg


type alias ToBackend =
    Bridge.ToBackend


type BackendMsg
    = OnConnect SessionId ClientId


type ToFrontend
    = NewSmashedLikes Int
