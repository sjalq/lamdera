module Pages.Stuff exposing (page)

import Html exposing (Html)
import View exposing (View)


page : View msg
page =
    { title = "Pages.Stuff"
    , body = [ Html.text "/stuff" ]
    }
