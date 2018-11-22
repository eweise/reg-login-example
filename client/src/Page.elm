module Page exposing (Page(..), view, viewErrors)

import Api exposing (Cred)
import Browser exposing (Document)
import Element as El exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html, a, button, div, footer, i, img, li, nav, p, section, span, text, ul)
import Html.Attributes exposing (class, classList, href, style)
import Html.Events exposing (onClick)
import Http as Http
import Json.Decode as Decode
import Route exposing (Route)
import Session exposing (Session)
import Style as Style
import Username exposing (Username)
import Viewer exposing (Viewer)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type Page
    = Other
    | Home
    | Login
    | Register
    | Settings
    | NewArticle


{-| Take a page's Html and frames it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
view : Maybe Viewer -> Page -> Maybe Http.Error -> { title : String, content : Element msg } -> Document msg
view maybeViewer page maybeError { title, content } =
    { title = title ++ " - Home"
    , body =
        [ El.layoutWith
            { options =
                []
            }
            [ Font.family
                [ Font.external
                    { url = "https://fonts.googleapis.com/css?family=Inconsolata"
                    , name = "Inconsolata"
                    }
                , Font.sansSerif
                ]
            ]
          <|
            let
                errorPanel =
                    case maybeError of
                        Just error ->
                            let
                                message =
                                    case error of
                                        Http.NetworkError ->
                                            El.text "Network Error"

                                        Http.BadUrl url ->
                                            El.text <| "Bad Url " ++ url

                                        Http.Timeout ->
                                            El.text "Server Timeout"

                                        Http.BadPayload value _ ->
                                            El.column [] <|
                                                List.map (\m -> El.text <| m) <|
                                                    decodeMessage value

                                        Http.BadStatus response ->
                                            El.column [] <|
                                                List.map (\m -> El.text <| m) <|
                                                    decodeMessage response.body
                            in
                            el
                                [ Background.color Style.red
                                , padding 10
                                , width El.fill
                                , Font.color Style.white
                                , Font.size 12
                                ]
                                (El.column [ centerX, centerY ] [ message ])

                        Nothing ->
                            El.column [] []
            in
            El.column [ width fill, height fill ]
                [ viewHeader page
                    maybeViewer
                , errorPanel
                , content
                ]
        ]
    }


decodeMessage : String -> List String
decodeMessage str =
    let
        d =
            Debug.log "json = " str

        messageList =
            case (Decode.decodeString <| Decode.field "messages" <| Decode.list Decode.string) str of
                Ok message ->
                    message

                Err err ->
                    [ "Unknown server error" ]
    in
    messageList


viewHeader : Page -> Maybe Viewer -> El.Element msg
viewHeader page maybeViewer =
    row
        [ width fill
        , padding 10
        , spacing 10
        , Background.color (rgba 50 50 30 1)
        ]
    <|
        case maybeViewer of
            Just viewer ->
                [ el [ alignLeft ] <| navbarLink page Route.Home "Tutoring"
                , el [ alignRight ] <| navbarLink page Route.Logout "Logout"
                ]

            Nothing ->
                [ el [ alignLeft ] <| navbarLink page Route.Home "Tutoring"
                , el [ alignRight ] <| navbarLink page Route.Login "Login"
                , el [ alignRight ] <| navbarLink page Route.Register "Register"
                ]


viewMenu : Page -> Maybe Viewer -> List (Element msg)
viewMenu page maybeViewer =
    let
        linkTo =
            navbarLink page
    in
    case maybeViewer of
        Just viewer ->
            let
                username =
                    Viewer.username viewer
            in
            [ linkTo Route.Logout "Sign out"
            ]

        Nothing ->
            [ linkTo Route.Login "Sign in"
            , linkTo Route.Register "Sign up"
            ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "footer" ]
            [ div [ class "content has-text-centered" ]
                [ a [ href "/" ] [ text "tutoring" ]
                ]
            ]
        ]


navbarLink : Page -> Route -> String -> Element msg
navbarLink page route label =
    Route.href route label


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Login, Route.Login ) ->
            True

        ( Register, Route.Register ) ->
            True

        _ ->
            False


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""

    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
