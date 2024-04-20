module Bridge exposing (..)
import Api.User exposing (User)


type ToBackend
    = SmashedLikeButton
    | AttemptLogin String String
    | AttemptUserRegistration String String
