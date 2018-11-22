module Page.Register exposing (Model, Msg, init, update, view)

import Api exposing (Cred)
import Browser.Navigation as Nav
import Element as El exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import OutMsg as OutMsg
import Route exposing (Route)
import Style exposing (..)
import Validation exposing (..)
import Viewer exposing (Viewer)


emailField =
    "register.email"


pwField =
    "register.password"


pwField2 =
    "register.password2"


type alias ValidationError =
    ( String, String )



-- MODEL


type alias Model =
    { problems : List ValidationError
    , form : Form
    }


type alias Form =
    { email : String
    , username : String
    , password : String
    , password2 : String
    }


init : ( Model, Cmd msg, OutMsg.OutMsg )
init =
    ( { problems = []
      , form =
            { email = ""
            , username = ""
            , password = ""
            , password2 = ""
            }
      }
    , Cmd.none
    , OutMsg.NoOutMsg
    )



-- VIEW


view : Model -> { title : String, content : El.Element Msg }
view model =
    { title = "Register"
    , content =
        Style.formGroup "Register"
            [ El.width <| px 500 ]
            [ Input.username
                (inputStyle (filterValidationErrors emailField model.problems))
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
            , Input.currentPassword
                (inputStyle <| filterValidationErrors pwField model.problems)
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
            , Input.currentPassword
                (inputStyle <| filterValidationErrors pwField2 model.problems)
                { text = model.form.password2
                , placeholder = Nothing
                , onChange = ReEnteredPassword
                , label =
                    Input.labelAbove
                        [ Font.size 14
                        , spacing 0
                        , padding 0
                        , moveDown 15
                        ]
                        (El.text "Reenter Password")
                , show = False
                }
            , row [ El.width fill, spacing 10 ]
                [ Input.button (primaryButtonStyle ++ [ alignLeft ])
                    { onPress = Just SubmittedForm
                    , label = El.text "Register"
                    }
                , El.row []
                    [ El.text "Already a user? Please "
                    , Route.href Route.Login "Login"
                    ]
                ]
            ]
    }


viewProblem : ValidationError -> Html msg
viewProblem problem =
    li [] [ Html.text <| Tuple.second problem ]


filterValidationErrors : String -> List ValidationError -> List String
filterValidationErrors field errors =
    List.filter (\value -> Tuple.first value == field) errors
        |> List.map (\value -> Tuple.second value)



-- UPDATE


type Msg
    = SubmittedForm
    | EnteredEmail String
    | EnteredUsername String
    | EnteredPassword String
    | ReEnteredPassword String
    | CompletedRegister (Result Http.Error Viewer)


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg.OutMsg )
update msg model =
    case msg of
        SubmittedForm ->
            case validate model.form of
                Ok validForm ->
                    ( { model | problems = [] }
                    , Http.send CompletedRegister (register validForm)
                    , OutMsg.NoOutMsg
                    )

                Err problems ->
                    ( { model | problems = problems }
                    , Cmd.none
                    , OutMsg.NoOutMsg
                    )

        EnteredUsername username ->
            updateForm (\form -> { form | username = username }) model

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        ReEnteredPassword password2 ->
            updateForm (\form -> { form | password2 = password2 }) model

        CompletedRegister (Err error) ->
            ( model
            , Cmd.none
            , OutMsg.ServerErr error
            )

        CompletedRegister (Ok viewer) ->
            ( model
            , Viewer.store viewer
            , OutMsg.NoOutMsg
            )


{-| Helper function for `update`. Updates the form and returns Cmd.none.
Useful for recording form fields!
-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg, OutMsg.OutMsg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none, OutMsg.NoOutMsg )



-- EXPORT
-- FORM


{-| Marks that we've trimmed the form's fields, so we don't accidentally send
it to the server without having trimmed it!
-}
type TrimmedForm
    = Trimmed Form


{-| When adding a variant here, add it to `fieldsToValidate` too!
-}
type ValidatedField
    = Email
    | Password


fieldsToValidate : List String
fieldsToValidate =
    [ emailField
    , pwField
    , pwField2
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
        "register.email" ->
            if String.isEmpty form.email then
                [ ( emailField, "email can't be blank." ) ]

            else
                []

        "register.password" ->
            if String.isEmpty form.password then
                [ ( "register.password", "password can't be blank." ) ]

            else if String.length form.password < Viewer.minPasswordChars then
                [ ( "register.password", "password must be at least " ++ String.fromInt Viewer.minPasswordChars ++ " characters long." ) ]

            else
                []

        "register.password2" ->
            if form.password /= form.password2 then
                [ ( "register.password2", "passwords do not match" ) ]

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
        { username = String.trim form.username
        , email = String.trim form.email
        , password = String.trim form.password
        , password2 = String.trim form.password2
        }



-- HTTP


register : TrimmedForm -> Http.Request Viewer
register (Trimmed form) =
    let
        body =
            Encode.object
                [ ( "username", Encode.string form.username )
                , ( "email", Encode.string form.email )
                , ( "password", Encode.string form.password )
                ]
                |> Http.jsonBody
    in
    Api.register body Viewer.decoder
