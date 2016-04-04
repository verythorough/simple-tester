module Main (..) where

import Test exposing (init, update, view)
import StartApp


app =
  StartApp.start
    { init = init testInfo
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port testInfo : ( Int, String )
