module Style exposing (addButton, black, blue, edges, formGroup, inputStyle, lightGray, primaryButtonStyle, red, secondaryButtonStyle, white)

import Element as El exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


white =
    El.rgb 10 10 10


black =
    El.rgb 0 0 0


blue =
    El.rgb 0.3 0.3 1.0


darkBlue =
    El.rgb 0 0 0.4


red =
    El.rgb 0.8 0.3 0.3


green =
    El.rgb 0 0.8 0


lightGray =
    El.rgb 0.95 0.95 0.95


gray =
    El.rgb 0.7 0.7 0.7


darkGray =
    El.rgb 0.6 0.6 0.6


link : List (Attribute msg) -> String -> String -> Element msg
link attrs url label =
    let
        defaultStyle =
            [ Font.color blue ]
    in
    El.link (List.append defaultStyle attrs) { url = url, label = El.el defaultStyle <| text label }


inputStyle : List String -> List (El.Attribute msg)
inputStyle errors =
    [ padding 5
    , spacing 20
    , Border.solid
    , Border.width 1
    , Border.color gray
    , Border.rounded 5
    ]
        ++ (if List.length errors > 0 then
                [ below <|
                    El.el
                        [ alignRight
                        , Font.size 14
                        , Font.color red
                        ]
                        (El.column [] (List.map (\error -> text error) errors))
                ]

            else
                []
           )


alert : String -> Element msg -> Element msg
alert message inFrontOfElement =
    column [ Background.color red, width fill ] [ El.text message ]


addButton : Element msg
addButton =
    Input.button
        [ paddingXY 11 0
        , Border.rounded 100
        , Font.size 50
        , Background.color green
        , Font.color white
        , Border.shadow
            { offset = ( 2, 2 )
            , size = 1
            , blur = 3
            , color = gray
            }
        ]
        { onPress = Nothing
        , label = text "+"
        }


primaryButtonStyle : List (El.Attribute msg)
primaryButtonStyle =
    buttonStyle
        ++ [ Background.color blue
           ]


secondaryButtonStyle : List (El.Attribute msg)
secondaryButtonStyle =
    buttonStyle
        ++ [ Background.color darkGray
           ]


buttonStyle : List (El.Attribute msg)
buttonStyle =
    [ paddingXY 20 10
    , Border.rounded 3
    , Font.color white
    , Border.shadow
        { offset = ( 2, 2 )
        , size = 1
        , blur = 3
        , color = gray
        }
    ]


formGroup : String -> List (Attribute msg) -> List (Element msg) -> Element msg
formGroup title attributes innerElements =
    column
        ([ Border.solid
         , Border.color darkGray
         , Border.shadow
            { offset = ( 2, 2 )
            , size = 1
            , blur = 5
            , color = gray
            }
         , Background.color lightGray
         , Border.rounded 0
         , width shrink
         , height shrink
         , spacing 20
         , centerX
         , centerY
         , padding 30
         , above
            (el
                [ Font.bold
                , centerX
                , moveDown 30
                ]
                (El.text title)
            )
         ]
            ++ attributes
        )
    <|
        innerElements
