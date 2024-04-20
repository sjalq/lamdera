module Api.User exposing (..)

import Crypto.Hash
import Env
import Lamdera exposing (SessionId)
import Random.Char
import Random.String
import Regex
import Random
import Time

type alias User =
    { email : String
    , passwordHash : String
    , role : Role
    , salt : String
    , sessionId : Maybe SessionId
    , sessionExpiration : Maybe Int  
    }


type alias Email =
    String


type alias Password =
    String


roleToString : Role -> String
roleToString role =
    case role of
        Admin ->
            "Admin"

        Basic ->
            "Basic"


stringToRole : String -> Role
stringToRole string =
    case string of
        "Admin" ->
            Admin

        _ ->
            Basic


isAdminEmail : String -> Bool
isAdminEmail email =
    let
        adminUsers =
            Env.adminUsers |> String.split ","
    in
    adminUsers |> List.member email



-- USER VALIDATION


validateUser :
    { email : String
    , password : String
    }
    -> ( Bool, Bool )
validateUser { email, password } =
    ( validateEmail email
    , password |> (not << String.isEmpty)
    )


validateEmail : String -> Bool
validateEmail email =
    email |> Regex.contains emailRegex


emailRegex : Regex.Regex
emailRegex =
    Regex.fromString "[^@ \\t\\r\\n]+@[^@ \\t\\r\\n]+\\.[^@ \\t\\r\\n]+" |> Maybe.withDefault Regex.never


randomSalt : Random.Generator String
randomSalt =
    Random.String.string 10 Random.Char.english


hashPassword : String -> String -> String
hashPassword password salt =
    Crypto.Hash.sha256 <| password ++ salt


type Role
    = Basic
    | Admin


type RequiredRole
    = Require Role


checkAuthorization : RequiredRole -> Role -> Bool
checkAuthorization required role =
    case required of
        Require requiredRole ->
            case ( role, requiredRole ) of
                ( Admin, _ ) ->
                    True

                ( Basic, Admin ) ->
                    False

                ( Basic, _ ) ->
                    True



-- For the frontend


isAdmin : Maybe User -> Bool
isAdmin maybeUser =
    maybeUser
        |> Maybe.map .role
        |> Maybe.map (checkAuthorization (Require Admin))
        |> Maybe.withDefault False
