module OutMsg exposing (OutMsg(..))

import Http exposing (Request)


type OutMsg
    = NoOutMsg
    | ServerErr Http.Error
