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


buttonStyle : List (Attribute msg)
buttonStyle =
    [ Background.color <| rgb 0.25 0.5 0.75
    , Font.color <| rgb 1 1 1
    , Border.rounded 5
    , padding 10
    , centerX
    ]


promptBorderStyle : List (Attribute msg)
promptBorderStyle =
    [ Border.rounded 5
    , Border.width 1
    , Border.color <| rgb 0.25 0.5 0.75
    , padding 10
    , spacing 10
    , centerX
    ]


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
                [ column [ Font.color <| rgb 1 0 0, Font.size 12, spacing 5 ]
                    [ text
                        "Passwords do not match"
                    ]
                ]

        submitButton =
            Input.button
                buttonStyle
                { onPress = Just Submit
                , label =
                    case model.mode of
                        Register ->
                            text "Register"

                        Login ->
                            text "Login"
                }

        modeSelector =
            let
                bgColor mode =
                    if model.mode == mode then
                        [ Background.color <| rgb 1 1 1
                        , Font.color <| rgb 0.25 0.5 0.75
                        ]

                    else
                        [ Background.color <| rgb 0.25 0.5 0.75
                        , Font.color <| rgb 1 1 1
                        ]
            in
            row [ spacing 10, centerX ]
                [ Input.button
                    (buttonStyle
                        ++ bgColor Register
                    )
                    { onPress = Just <| ChangeMode Login
                    , label = text "Login"
                    }
                , Input.button
                    (buttonStyle
                        ++ bgColor Login
                    )
                    { onPress = Just <| ChangeMode Register
                    , label = text "Register"
                    }
                ]
    in
    column promptBorderStyle
        (modeSelector
            :: emailInput
            :: passwordInput
            :: (if model.mode == Register then
                    [ confirmPasswordInput ]
                        ++ passwordsMatchIndicator

                else
                    []
               )
            ++ [ submitButton ]
        )
