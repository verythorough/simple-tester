module Test (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects)
import Task exposing (Task)
import String


-- MODEL


type alias Model =
  { id : TestId
  , description : String
  , status : String
  }



--Id isn't really needed at the test level, and works better in TestRunner
--Will refactor to match this


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
  = StartTest
  | ResultStatus Bool
  | DoNothing


update : Signal.Address TestId -> Action -> Model -> ( Model, Effects Action )
update startAddress action model =
  case action of
    StartTest ->
      ( { model | status = "Running" }
      , startTest startAddress model.id
      )

    ResultStatus hasPassed ->
      ( if hasPassed == True then
          { model | status = "Passed" }
        else
          { model | status = "Failed" }
      , Effects.none
      )

    DoNothing ->
      ( model, Effects.none )



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class ("test " ++ statusToClass model.status) ]
    [ p
        [ class "test-description" ]
        [ text ("Test that: " ++ model.description) ]
    , button
        [ onClick address (StartTest) ]
        [ text "Start Test" ]
    , span
        (liveArea [ class "test-status" ])
        [ text (" Status: " ++ model.status) ]
    ]


viewInTable : Signal.Address Action -> Model -> Html
viewInTable address model =
  tr
    [ class ("test " ++ statusToClass model.status) ]
    [ td
        [ class "test-description" ]
        [ text model.description ]
    , td
        [ class "test-status" ]
        [ text model.status ]
    ]


statusToClass : String -> String
statusToClass status =
  String.toLower status
    |> String.split " "
    |> String.join "-"



-- Adds necessary attributes for screen-reader updates on state change


liveArea : List Html.Attribute -> List Html.Attribute
liveArea additionalAttributes =
  List.append
    additionalAttributes
    [ attribute "role" "status"
    , attribute "aria-live" "polite"
    , attribute "aria-atomic" "false"
    ]



-- EFFECTS


startTest : Signal.Address TestId -> TestId -> Effects Action
startTest startAddress id =
  let
    sendTask =
      Signal.send startAddress id
        |> Task.map (\_ -> DoNothing)
  in
    Task.onError sendTask (\_ -> Task.succeed DoNothing)
      |> Effects.task
