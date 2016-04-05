module Main (..) where

import Test exposing (initialModel, update, view)
import StartApp
import Task exposing (Task)
import Effects


app =
  StartApp.start
    { init = ( initialModel testInfo, Effects.none )
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


run : Signal.Mailbox Int
run =
  Signal.mailbox -1


port testRun : Signal Int
port testRun =
  run.signal


port testInfo : ( Int, String )
