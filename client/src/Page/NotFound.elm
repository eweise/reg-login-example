module Page.NotFound exposing (view)

import Asset
import Element as El exposing (Element)
import Html exposing (Html, div, h1, img, main_, text)
import Html.Attributes exposing (alt, class, id, src, tabindex)



-- VIEW


view : { title : String, content : Element msg }
view =
    { title = "Page Not Found"
    , content =
        El.text "Page not found"
    }
