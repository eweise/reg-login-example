module Main exposing (createResultMsg, main)

import Api exposing (Cred)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Element exposing (Element)
import Html exposing (..)
import Http as Http
import Json.Decode as Decode exposing (Value)
import OutMsg as OutMsg
import Page exposing (Page)
import Page.Blank as Blank
import Page.Home as Home
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Register as Register
import Route exposing (Route)
import Session exposing (Session(..))
import Task
import Time
import Url exposing (Url)
import Username exposing (Username)
import Validation exposing (Problem)
import Viewer exposing (Viewer)



-- NOTE: Based on discussions around how asset management features
-- like code splitting and lazy loading have been shaping up, it's possible
-- that most of this file may become unnecessary in a future release of Elm.
-- Avoid putting things in this module unless there is no alternative!
-- See https://discourse.elm-lang.org/t/elm-spa-in-0-19/1800/2 for more.


type Msg
    = Ignored
    | OutMsg OutMsg.OutMsg
    | ServerError Http.Error
    | ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotLoginMsg Login.Msg
    | GotRegisterMsg Register.Msg
    | GotSession Session


type PageModel
    = Redirect
    | NotFound
    | Home Home.Model
    | Login Login.Model
    | Register Register.Model


type alias Model =
    { session : Session
    , error : Maybe Http.Error
    , pageModel : PageModel
    }



-- MODEL


initModel : Nav.Key -> PageModel -> Model
initModel navKey pageModel =
    { session = Guest navKey
    , error = Nothing
    , pageModel = pageModel
    }


init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    let
        ( pageModel, cmd ) =
            changeRouteTo (Route.fromUrl url) navKey Redirect
    in
    ( initModel navKey pageModel, cmd )



-- VIEW


view : Model -> Document Msg
view model =
    let
        --        viewPage : Page -> (a -> Msg) -> { title : String, content : Element msg } -> Document Msg
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view (Session.viewer model.session) page model.error config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model.pageModel of
        Redirect ->
            viewPage Page.Other (\_ -> Ignored) Blank.view

        NotFound ->
            viewPage Page.Other (\_ -> Ignored) NotFound.view

        Home home ->
            viewPage Page.Home GotHomeMsg (Home.view home)

        Login login ->
            let
                result =
                    viewPage Page.Login GotLoginMsg (Login.view login)
            in
            result

        Register register ->
            viewPage Page.Other GotRegisterMsg (Register.view register)



-- UPDATE


changeRouteTo : Maybe Route -> Nav.Key -> PageModel -> ( PageModel, Cmd Msg )
changeRouteTo maybeRoute navKey model =
    case maybeRoute of
        Nothing ->
            ( NotFound, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl navKey Route.Home )

        Just Route.Logout ->
            ( model, Api.logout )

        Just Route.Home ->
            Home.init
                |> updateWith Home GotHomeMsg model

        Just Route.Login ->
            Login.init
                |> updateWith Login GotLoginMsg model

        Just Route.Register ->
            Register.init
                |> updateWith Register GotRegisterMsg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updateAfterReset msg { model | error = Nothing }


updateAfterReset : Msg -> Model -> ( Model, Cmd Msg )
updateAfterReset msg model =
    case ( msg, model.pageModel ) of
        ( ServerError err, _ ) ->
            ( { model | error = Just err }, Cmd.none )

        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Nav.pushUrl (Session.navKey model.session) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            let
                ( pageModel, subMsg ) =
                    changeRouteTo (Route.fromUrl url) (Session.navKey model.session) model.pageModel
            in
            ( { model | pageModel = pageModel }, subMsg )

        ( ChangedRoute route, _ ) ->
            let
                ( pageModel, subMsg ) =
                    changeRouteTo route (Session.navKey model.session) model.pageModel
            in
            ( { model | pageModel = pageModel }, subMsg )

        ( GotLoginMsg subMsg, Login login ) ->
            let
                ( newPageModel, cmd, outMsg ) =
                    Login.update subMsg login

                ( pageModel, newMsg ) =
                    updateWith Login GotLoginMsg model.pageModel ( newPageModel, cmd, outMsg )
            in
            prepareResult model pageModel newMsg outMsg

        ( GotRegisterMsg subMsg, Register register ) ->
            let
                ( newPageModel, cmd, outMsg ) =
                    Register.update subMsg register

                ( pageModel, newMsg ) =
                    updateWith Register GotRegisterMsg model.pageModel ( newPageModel, cmd, outMsg )
            in
            prepareResult model pageModel newMsg outMsg

        ( GotHomeMsg subMsg, Home home ) ->
            let
                ( pageModel, newMsg ) =
                    Home.update subMsg home
                        |> updateWith Home GotHomeMsg model.pageModel
            in
            ( { model | pageModel = pageModel }, newMsg )

        ( GotSession session, Redirect ) ->
            let
                ( pageModel, newMsg ) =
                    ( Redirect
                    , Route.replaceUrl (Session.navKey model.session) Route.Home
                    )
            in
            ( { model | session = session, pageModel = pageModel }, newMsg )

        ( GotSession session, _ ) ->
            let
                ( pageModel, newMsg ) =
                    ( Redirect
                    , Route.replaceUrl (Session.navKey model.session) Route.Home
                    )
            in
            ( { model | session = session, pageModel = pageModel }, newMsg )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            Debug.log "Main.update no matching event" ( model, Cmd.none )


updateWith :
    (subModel -> PageModel)
    -> (subMsg -> Msg)
    -> PageModel
    -> ( subModel, Cmd subMsg, OutMsg.OutMsg )
    -> ( PageModel, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd, outMsg ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


prepareResult : Model -> PageModel -> Cmd Msg -> OutMsg.OutMsg -> ( Model, Cmd Msg )
prepareResult model pageModel msg outMsg =
    ( { model
        | pageModel = pageModel
        , error =
            case outMsg of
                OutMsg.ServerErr err ->
                    Just err

                OutMsg.NoOutMsg ->
                    Nothing
      }
    , msg
    )


createResultMsg : (a -> Msg) -> (Result Http.Error a -> Msg)
createResultMsg msg =
    \result ->
        case result of
            Ok a ->
                msg a

            Err value ->
                ServerError value



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- MAIN


main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
