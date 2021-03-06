module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Element as El
import Element.Font as Font
import Html exposing (Attribute)
import Html.Attributes as Attr
import Profile exposing (Profile)
import Style exposing (blue)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)
import Username exposing (Username)



-- ROUTING


type Route
    = Home
    | Root
    | Login
    | Logout
    | Register


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (s "login")
        , Parser.map Logout (s "logout")
        , Parser.map Register (s "register")
        ]



-- PUBLIC HELPERS


href : Route -> String -> El.Element msg
href targetRoute label =
    El.link []
        { url = routeToString targetRoute
        , label = El.el [ Font.color blue ] (El.text label)
        }


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Root ->
                    []

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                Register ->
                    [ "register" ]
    in
    "#/" ++ String.join "/" pieces
