module Bridge exposing (..)
import Api.User exposing (..)


type ToBackend
    = SmashedLikeButton
    | AttemptLogin Email Password
    | AttemptUserRegistration Email Password
