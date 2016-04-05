module Test (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects)
import Task exposing (Task)
import String


-- MODEL
-- type alias Model =
--   String
--
--
-- init : String -> ( Model, Effects Action )
-- init topic =
--   ( topic
--   , Effects.none
--   )


type alias Model =
  { id : TestId
  , description : String
  , status : String
  }


type alias TestId =
  Int


initialModel : ( Int, String ) -> Model
initialModel ( id, desc ) =
  { id = id
  , description = desc
  , status = "Not Started Yet"
  }



-- UPDATE


type Action
  = StartTest TestId
  | TestResult
  | DoNothing


update : Signal.Address TestId -> Action -> Model -> ( Model, Effects Action )
update startAddress action model =
  case action of
    StartTest id ->
      ( { model | status = "Running" }
      , Effects.task (startTask startAddress model.id)
      )

    TestResult ->
      ( model, Effects.none )

    DoNothing ->
      ( model, Effects.none )


startTask : Signal.Address TestId -> TestId -> Task x Action
startTask address id =
  let
    task =
      Signal.send address id
        |> Task.map (\_ -> DoNothing)
  in
    Task.onError task (\_ -> Task.succeed DoNothing)



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class ("test " ++ statusToClass model.status) ]
    [ p
        [ class "test-description" ]
        [ text ("Test that: " ++ model.description) ]
    , button
        [ onClick address (StartTest model.id) ]
        [ text "Start Test" ]
    , span
        [ class "test-status" ]
        [ text (" Status: " ++ model.status) ]
    ]


statusToClass : String -> String
statusToClass status =
  String.toLower status
    |> String.split " "
    |> String.join "-"
