module Api.User exposing (..)
import Lamdera exposing (SessionId)

type alias User =
    { email : String
    , passwordHash : String
    , salt : String
    , sessionId : Maybe SessionId
    }

type alias Email = String