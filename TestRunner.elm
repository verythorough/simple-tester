module TestRunner (..) where

import Test exposing (TestId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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

    --TODO: combine SubMsg and PassResult into one message
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
            fst (Test.update startAddress (Test.ResultStatus ( id, hasPassed )) testModel)
          else
            testModel

        newState =
          if statusTally model.tests "Running" == 0 then
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
    pTag msg =
      p [] [ text msg ]

    runningStr =
      statusTally model.tests "Running" |> toString

    passedStr =
      statusTally model.tests "Passed" |> toString

    failedStr =
      statusTally model.tests "Failed" |> toString

    passOrFailSummary =
      if statusTally model.tests "Passed" == List.length model.tests then
        ("Woohoo! All " ++ passedStr ++ " tests passed!")
      else
        (passedStr ++ " passed; " ++ failedStr ++ " failed.")

    elementsByState =
      case model.state of
        Waiting ->
          [ pTag "Waiting for Tests..." ]

        Loaded ->
          [ pTag "Use the Start button to run the following tests:"
          , button [ onClick address (SubMsg (Test.StartTest)) ] [ text "Start" ]
          , (viewTestTable address model)
          ]

        Started ->
          [ pTag "Tests Started!"
          , pTag (runningStr ++ " running; " ++ passedStr ++ " passed; " ++ failedStr ++ " failed.")
          , (viewTestTable address model)
          ]

        Finished ->
          [ pTag "FINISHED!"
          , pTag passOrFailSummary
          , (viewTestTable address model)
          ]
  in
    div [] elementsByState


viewTestTable : Signal.Address Action -> Model -> Html
viewTestTable address model =
  table
    []
    [ thead
        []
        [ tr
            []
            [ th [] [ text "Status" ]
            , th [] [ text "Test Number/Description" ]
            ]
        ]
    , tbody
        []
        (List.map (viewTest address) model.tests)
    ]


viewTest : Signal.Address Action -> Test.Model -> Html
viewTest address model =
  Test.viewInTable (Signal.forwardTo address SubMsg) model



-- viewCounter : Signal.Address Action -> ( ID, Counter.Model ) -> Html
-- viewCounter address ( id, model ) =
--   let
--     context =
--       Counter.Context
--         (Signal.forwardTo address (Modify id))
--         (Signal.forwardTo address (always (Remove id)))
--   in
--     Counter.viewWithRemoveButton context model
-- EFFECTS


loadTests : List ( Int, String ) -> Effects Action
loadTests testList =
  BuildTests testList
    |> Task.succeed
    |> Effects.task
