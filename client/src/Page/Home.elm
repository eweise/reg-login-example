module Page.Home exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Browser.Dom as Dom
import Element as El exposing (Element)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)
import Http
import Loading
import Log
import OutMsg as OutMsg
import Page
import PaginatedList exposing (PaginatedList)
import Task exposing (Task)
import Time
import Url.Builder
import Username exposing (Username)



-- MODEL


type alias Model =
    { timeZone : Time.Zone
    }


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : ( Model, Cmd Msg, OutMsg.OutMsg )
init =
    ( { timeZone = Time.utc
      }
    , Cmd.batch
        [ Task.perform GotTimeZone Time.here
        ]
    , OutMsg.NoOutMsg
    )



-- VIEW


view : Model -> { title : String, content : Element Msg }
view model =
    { title = "Tutoring Connection"
    , content =
        El.el [] <| El.text "Main page"
    }


viewBanner : Html msg
viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "Tutoring" ]
            , p [] [ text "A place to connect with Tutors." ]
            ]
        ]



-- TABS
-- TAGS
-- UPDATE


type Msg
    = GotTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg.OutMsg )
update msg model =
    case msg of
        GotTimeZone tz ->
            ( { model | timeZone = tz }, Cmd.none, OutMsg.NoOutMsg )



-- HTTP


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())
