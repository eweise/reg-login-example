module Validation exposing (Problem(..), filterValidationErrors)


type Problem
    = InvalidEntry String String
    | ServerError String


filterValidationErrors : String -> List Problem -> List String
filterValidationErrors validationField problems =
    let
        problemText =
            \problem ->
                case problem of
                    InvalidEntry field errorText ->
                        if validationField == field then
                            Just errorText

                        else
                            Nothing

                    ServerError a ->
                        Nothing
    in
    List.map problemText problems
        |> List.filter (\maybe -> maybe /= Nothing)
        |> List.map
            (\maybe ->
                case maybe of
                    Just a ->
                        a

                    Nothing ->
                        ""
            )
