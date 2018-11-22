module Profile exposing (Profile, bio, decoder)

{-| A user's profile - potentially your own!

Contrast with Cred, which is the currently signed-in user.

-}

import Api exposing (Cred)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Username exposing (Username)



-- TYPES


type Profile
    = Profile Internals


type alias Internals =
    { bio : Maybe String
    }



-- INFO


bio : Profile -> Maybe String
bio (Profile info) =
    info.bio



-- SERIALIZATION


decoder : Decoder Profile
decoder =
    Decode.succeed Internals
        |> required "bio" (Decode.nullable Decode.string)
        |> Decode.map Profile
