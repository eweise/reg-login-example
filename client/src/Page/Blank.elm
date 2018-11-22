module Page.Blank exposing (view)

import Element as El
import Html exposing (Html)


view : { title : String, content : El.Element msg }
view =
    { title = ""
    , content = El.text ""
    }
