module TestRunner (..) where

import Test exposing (TestId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import A11y
import Effects exposing (Effects)
import Task


-- MODEL


type alias Model =
  { tests : List Test.Model
  , state : TestingState
  }


type TestingState
  = Waiting
  | Loaded
  | Started
  | Finished


init : List ( Int, String ) -> ( Model, Effects Action )
init testList =
  ( Model [] Waiting
  , loadTests testList
  )



-- UPDATE


type Action
  = BuildTests (List ( Int, String ))
  | SubMsg Test.Action
  | PassResult ( Int, Bool )
  | DoNothing


update : Signal.Address TestId -> Action -> Model -> ( Model, Effects Action )
update startAddress action model =
  case action of
    BuildTests testList ->
      ( Model
          (List.map Test.initialModel testList)
          Loaded
      , Effects.none
      )

    --TODO: combine SubMsg and PassResult into one, modular action?
    SubMsg msg ->
      let
        subUpdate test =
          let
            ( updatedTest, fx ) =
              Test.update startAddress msg test
          in
            ( updatedTest
            , Effects.map (SubMsg) fx
            )

        ( newTestList, fxList ) =
          model.tests
            |> List.map subUpdate
            |> List.unzip

        newState =
          if msg == Test.StartTest then
            Started
          else
            model.state
      in
        ( { model | tests = newTestList, state = newState }
        , Effects.batch fxList
        )

    PassResult ( id, hasPassed ) ->
      let
        updateStatus testModel =
          if testModel.id == id then
            fst ((Test.update startAddress (Test.ResultStatus hasPassed)) testModel)
          else
            testModel

        newState =
          if statusTally model.tests "Running" <= 1 then
            Finished
          else
            model.state
      in
        ( { model | tests = List.map updateStatus model.tests, state = newState }
        , Effects.none
        )

    DoNothing ->
      ( model, Effects.none )


statusTally : List Test.Model -> String -> Int
statusTally testList status =
  List.filter (\test -> test.status == status) testList
    |> List.length



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  let
    passOrFailMsg =
      if statusTally model.tests "Passed" == List.length model.tests then
        "Woohoo! All tests passed!"
      else
        "Tests complete.  Some tests failed. :("

    elementsByState =
      case model.state of
        Waiting ->
          [ p [] [ text "Waiting for Tests..." ] ]

        Loaded ->
          [ p
              -- Assigning a class enables special styling for the text/button
              --  combo in this state.
              [ class "start-message" ]
              [ span
                  (A11y.liveArea [])
                  [ text "Use the Start button to run the following tests:" ]
              , button [ onClick address (SubMsg Test.StartTest) ] [ text "Start" ]
              ]
          , (viewTestTable address model)
          ]

        Started ->
          [ p (A11y.liveArea []) [ text "Tests Started!" ]
          , (viewTestTable address model)
          ]

        Finished ->
          [ p (A11y.liveArea []) [ text passOrFailMsg ]
          , (viewTestTable address model)
          ]
  in
    div [] elementsByState


viewTestTable : Signal.Address Action -> Model -> Html
viewTestTable address model =
  let
    statusToMsg status predicate =
      -- "predicate" is the string following the number, e.g. " tests passed; "
      ((statusTally model.tests status |> toString) ++ predicate)
  in
    table
      [ class "results-table" ]
      -- Storing the summary in a caption increases semantic accessibility
      [ caption
          [ class "results-summary" ]
          -- Splitting this into spans enables graceful wrapping at narrow widths
          [ strong [] [ text "Tests Summary: " ]
          , span [] [ text (statusToMsg "Passed" " passed; ") ]
          , span [] [ text (statusToMsg "Failed" " failed; ") ]
          , span [] [ text (statusToMsg "Running" " are still running.") ]
          ]
      , thead
          []
          [ tr
              []
              [ th [] [ text "Status" ]
              , th [] [ text "Test Description" ]
              ]
          ]
      , tbody
          []
          (List.map (viewTest address) model.tests)
      ]


viewTest : Signal.Address Action -> Test.Model -> Html
viewTest address model =
  Test.viewInTable (Signal.forwardTo address (SubMsg)) model



-- EFFECTS
--
--
--TODO: account for errors here?


loadTests : List ( Int, String ) -> Effects Action
loadTests testList =
  BuildTests testList
    |> Task.succeed
    |> Effects.task
