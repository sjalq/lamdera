module Backend exposing (..)

import Api.User exposing (..)
import Bridge exposing (..)
import Dict
import Html
import Lamdera exposing (ClientId, SessionId)
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontendTimestamped
        , subscriptions = \m -> Lamdera.onConnect OnConnect
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { smashedLikes = 0
      , users = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        OnConnect sid cid ->
            ( model, Lamdera.sendToFrontend cid <| NewSmashedLikes model.smashedLikes )

        DoWithTime sid cid toBackendMsg time ->
            updateFromFrontend sid cid time toBackendMsg model


updateFromFrontendTimestamped : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontendTimestamped sessionId clientId msg model =
    ( model 
    , Time.now
        |> Task.perform (\t -> DoWithTime sessionId clientId msg t))


updateFromFrontend : SessionId -> ClientId -> Time.Posix -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId time msg model =
    case msg of
        SmashedLikeButton ->
            let
                newSmashedLikes =
                    model.smashedLikes + 1
            in
            ( { model | smashedLikes = newSmashedLikes }, Lamdera.broadcast <| NewSmashedLikes newSmashedLikes )

        AttemptLogin email password ->
            let
                attemptingUser =
                    Dict.get email model.users

                passwordMatches =
                    attemptingUser |> Maybe.map (\u -> hashPassword password u.salt == u.passwordHash)

                newUsers =
                    case ( attemptingUser, passwordMatches ) of
                        ( Just _, Just True ) ->
                            model.users

                        _ ->
                            Dict.insert email password model.users
            in
            ( { model
                | users = Dict.insert email password model.users
              }
            , Cmd.none
            )

        AttemptUserRegistration email password ->
            Debug.todo "branch 'AttemptUserRegistration _ _' not implemented"
