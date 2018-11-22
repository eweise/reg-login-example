module Page.Login exposing (Model, Msg, init, update, view)

{-| The login page.
-}

import Api exposing (Cred)
import Browser.Navigation as Nav
import Element as El exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import OutMsg exposing (OutMsg(..))
import Route exposing (Route)
import Style exposing (..)
import Validation exposing (..)
import Viewer exposing (Viewer)


type alias ValidationError =
    ( String, String )



-- MODEL


emailField =
    "login.email"


pwField =
    "login.password"


type alias Model =
    { problems : List ValidationError
    , form : Form
    }


type alias Form =
    { email : String
    , password : String
    }


init : ( Model, Cmd msg, OutMsg.OutMsg )
init =
    ( { problems = []
      , form =
            { email = ""
            , password = ""
            }
      }
    , Cmd.none
    , OutMsg.NoOutMsg
    )



-- VIEW


view : Model -> { title : String, content : El.Element Msg }
view model =
    { title = "Login"
    , content =
        Style.formGroup "Login"
            [ El.width <| px 500 ]
            [ Input.username (inputStyle (filterValidationErrors emailField model.problems))
                { text = model.form.email
                , placeholder = Just (Input.placeholder [] (El.text "username"))
                , onChange = EnteredEmail
                , label =
                    Input.labelAbove
                        [ Font.size 14
                        , spacing 0
                        , padding 0
                        , moveDown 15
                        ]
                        (El.text "Username")
                }
            , Input.currentPassword (inputStyle (filterValidationErrors pwField model.problems))
                { text = model.form.password
                , placeholder = Nothing
                , onChange = EnteredPassword
                , label =
                    Input.labelAbove
                        [ Font.size 14
                        , spacing 0
                        , padding 0
                        , moveDown 15
                        ]
                        (El.text "Password")
                , show = False
                }
            , row [ El.width fill, spacing 20 ]
                [ Input.button (primaryButtonStyle ++ [ alignLeft ])
                    { onPress = Just SubmittedForm
                    , label = El.text "Login"
                    }
                , El.row []
                    [ El.text "Not yet a user? Please "
                    , Route.href Route.Register "Register"
                    ]
                ]
            ]
    }



-- UPDATE


type Msg
    = SubmittedForm
    | EnteredEmail String
    | EnteredPassword String
    | CompletedLogin (Result Http.Error Viewer)


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        SubmittedForm ->
            case validate model.form of
                Ok validForm ->
                    ( { model | problems = [] }
                    , Http.send CompletedLogin (login validForm)
                    , OutMsg.NoOutMsg
                    )

                Err problems ->
                    ( { model | problems = problems }
                    , Cmd.none
                    , OutMsg.NoOutMsg
                    )

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        CompletedLogin (Err error) ->
            ( model
            , Cmd.none
            , ServerErr (Debug.log "completedLogin error = " error)
            )

        CompletedLogin (Ok viewer) ->
            ( model
            , Viewer.store viewer
            , OutMsg.NoOutMsg
            )


{-| Helper function for `update`. Updates the form and returns Cmd.none.
Useful for recording form fields!
-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg, OutMsg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none, OutMsg.NoOutMsg )


filterValidationErrors : String -> List ValidationError -> List String
filterValidationErrors field errors =
    List.filter (\value -> Tuple.first value == field) errors
        |> List.map (\value -> Tuple.second value)



-- FORM


{-| Marks that we've trimmed the form's fields, so we don't accidentally send
it to the server without having trimmed it!
-}
type TrimmedForm
    = Trimmed Form


fieldsToValidate : List String
fieldsToValidate =
    [ emailField
    , pwField
    ]


{-| Trim the form and validate its fields. If there are problems, report them!
-}
validate : Form -> Result (List ValidationError) TrimmedForm
validate form =
    let
        trimmedForm =
            trimFields form
    in
    case List.concatMap (validateField trimmedForm) fieldsToValidate of
        [] ->
            Ok trimmedForm

        problems ->
            Err problems


validateField : TrimmedForm -> String -> List ValidationError
validateField (Trimmed form) field =
    case field of
        "login.email" ->
            if String.isEmpty form.email then
                [ ( emailField, "email can't be blank." ) ]

            else
                []

        "login.password" ->
            if String.isEmpty form.password then
                [ ( pwField, "password can't be blank." ) ]

            else
                []

        _ ->
            []


{-| Don't trim while the user is typing! That would be super annoying.
Instead, trim only on submit.
-}
trimFields : Form -> TrimmedForm
trimFields form =
    Trimmed
        { email = String.trim form.email
        , password = String.trim form.password
        }



-- HTTP


login : TrimmedForm -> Http.Request Viewer
login (Trimmed form) =
    let
        body =
            Encode.object
                [ ( "email", Encode.string form.email )
                , ( "password", Encode.string form.password )
                ]
                |> Http.jsonBody
    in
    Api.login body Viewer.decoder
