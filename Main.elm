module Main (..) where

import Test exposing (initialModel, update, view, TestId)
import StartApp
import Task exposing (Task)
import Effects


app =
  StartApp.start
    { init = ( initialModel testInfo, Effects.none )
    , update = update startTestMb.address
    , view = view
    , inputs = [ Signal.map Test.ResultStatus testResult ]
    }


main =
  app.html


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


startTestMb : Signal.Mailbox TestId
startTestMb =
  Signal.mailbox -1


port testStart : Signal TestId
port testStart =
  startTestMb.signal


port testInfo : ( TestId, String )
port testResult : Signal ( TestId, Bool )
