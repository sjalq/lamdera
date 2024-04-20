module Pages.Login exposing (Model, Msg, page)

import Api.User exposing (User)
import Bridge exposing (ToBackend(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Lamdera
import Page exposing (Page)
import View exposing (View)


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { mode : Mode
    , email : String
    , password : String
    , confirmPassword : String
    }


init : ( Model, Cmd Msg )
init =
    ( { mode = Login
      , email = ""
      , password = ""
      , confirmPassword = ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | ChangeMode Mode
    | ChangeEmail String
    | ChangePassword String
    | ChangeConfirmPassword String
    | Submit


type Mode
    = Login
    | Register


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        ChangeMode mode ->
            ( { model | mode = mode }
            , Cmd.none
            )

        ChangeEmail email ->
            ( { model | email = email }
            , Cmd.none
            )

        ChangePassword password ->
            ( { model | password = password }
            , Cmd.none
            )

        ChangeConfirmPassword confirmPassword ->
            ( { model | confirmPassword = confirmPassword }
            , Cmd.none
            )

        Submit ->
            ( model
            , if model.mode == Login then
                Lamdera.sendToBackend <| AttemptLogin model.email model.password

              else
                Lamdera.sendToBackend <| AttemptUserRegistration model.email model.password
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Login"
    , body =
        [ layout [] <| viewUserManagement model
        ]
    }


viewUserManagement model =
    let
        emailInput =
            Input.text []
                { onChange = ChangeEmail
                , text = model.email
                , placeholder = Just <| Input.placeholder [] (text "Enter your email")
                , label = Input.labelLeft [] <| text "Email"
                }

        passwordInput =
            if model.mode == Login then
                Input.currentPassword []
                    { onChange = ChangePassword
                    , text = model.password
                    , placeholder = Just <| Input.placeholder [] (text "Enter your password")
                    , label = Input.labelLeft [] <| text "Password"
                    , show = False
                    }

            else
                Input.newPassword []
                    { onChange = ChangePassword
                    , text = model.password
                    , placeholder = Just <| Input.placeholder [] (text "Enter your password")
                    , label = Input.labelLeft [] <| text "Password"
                    , show = False
                    }

        confirmPasswordInput =
            Input.newPassword []
                { onChange = ChangeConfirmPassword
                , text = model.confirmPassword
                , placeholder = Just <| Input.placeholder [] (text "Confirm your password")
                , label = Input.labelLeft [] <| text "Confirm Password"
                , show = False
                }

        passwordsMatchIndicator =
            if model.password == model.confirmPassword then
                []

            else
                [ text "Passwords do not match" ]

        button =
            Input.button
                [ Background.color <| rgb 0.25 0.5 0.75, Font.color <| rgb 1 1 1 ]
                { onPress = Just Submit
                , label =
                    case model.mode of
                        Register ->
                            text "Register"

                        Login ->
                            text "Login"
                }
    in
    column [ spacing 20, padding 20, width fill ]
        (emailInput
            :: passwordInput
            :: (if model.mode == Register then
                    [ confirmPasswordInput ]
                        ++ passwordsMatchIndicator

                else
                    []
               )
            ++ [ button ]
        )
