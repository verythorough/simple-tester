module Main (..) where

import TestRunner exposing (init, update, view)
import StartApp
import Task exposing (Task)
import Effects


app =
  StartApp.start
    { init = init testInfo
    , update = update startTestMb.address
    , view = view
    , inputs = [ Signal.map TestRunner.PassResult testResult ]
    }


main =
  app.html


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


startTestMb : Signal.Mailbox Int
startTestMb =
  Signal.mailbox -1


port testStart : Signal Int
port testStart =
  startTestMb.signal


port testInfo : List ( Int, String )
port testResult : Signal ( Int, Bool )
