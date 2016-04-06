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
  , message : String
  }



-- initialModel : List ( Int, String ) -> Model
-- initialModel testList =
--   { tests = List.map (\( id, desc ) -> Test.initialModel ( id, desc )) testList
--   , message = "Use the Start button to run the following tests:"
--   }


init : List ( Int, String ) -> ( Model, Effects Action )
init testList =
  ( Model [] "Waiting for tests..."
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
          "Use the Start button to run the following tests:"
      , Effects.none
      )

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
      in
        ( { model | tests = newTestList }
        , Effects.batch fxList
        )

    PassResult ( id, hasPassed ) ->
      let
        updateStatus testModel =
          if testModel.id == id then
            fst (Test.update startAddress (Test.ResultStatus ( id, hasPassed )) testModel)
          else
            testModel
      in
        ( { model | tests = List.map updateStatus model.tests }
        , Effects.none
        )

    --
    --
    -- ResultStatus ( id, hasPassed ) ->
    --   ( if hasPassed == True then
    --       { model | status = "Passed" }
    --     else
    --       { model | status = "Failed" }
    --   , Effects.none
    --   )
    --
    DoNothing ->
      ( model, Effects.none )



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  let
    totalTally =
      List.length model.tests

    notStartedTally =
      statusTally model.tests "Not Started Yet"

    runningTally =
      statusTally model.tests "Running"

    passedTally =
      statusTally model.tests "Passed"

    failedTally =
      statusTally model.tests "Failed"

    message =
      if (passedTally + failedTally == totalTally) then
        "Tests Complete!"
      else if (runningTally > 0) then
        "Tests Started!"
      else
        model.message
  in
    div
      []
      [ p [] [ text message ]
      , button [ onClick address (SubMsg (Test.StartTest)) ] [ text "Start" ]
      , table
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
              (List.map (testView address) model.tests)
          ]
      , p
          []
          [ text
              ("Running: "
                ++ (runningTally |> toString)
                ++ " Passed: "
                ++ (passedTally |> toString)
                ++ " Failed: "
                ++ (failedTally |> toString)
              )
          ]
      ]



-- messageView : Model -> Html
-- messageView model =
--   let
--     totalTally = List.length model.tests
--     notStartedTally = statusTally model.tests "Not Started Yet"
--     runningTally = statusTally model.tests "Running"
--     passedTally = statusTally model.tests "Passed"
--     failedTally = statusTally model.tests "Failed"
--   in
--     if totalTally == 0 then
--       p [] [ text "Waiting for tests..." ]
--     else if notStartedTally == totalTally then
--       p [] [ text "Use the Start button to run the following tests:" ]
--     else if runningTally + passedTally + failedTally = totalTally then
--       div []
--         [ h2 [] Totals:
--         , span [] [ test ("Tests running: ")]
--
--         ]


statusTally : List Test.Model -> String -> Int
statusTally testList status =
  List.filter (\test -> test.status == status) testList
    |> List.length



-- view : Signal.Address Action -> Model -> Html
-- view address model =
--   let
--     counts =
--       p
--         []
--         [ text
--             (toString (List.length model.counters)
--               ++ " Counters, "
--               ++ toString (List.sum (List.map snd model.counters))
--               ++ " Counted"
--             )
--         ]
--
--     insert =
--       button [ onClick address Insert ] [ text "Add" ]
--   in
--     div [] (counts :: insert :: List.map (viewCounter address) model.counters)


testView : Signal.Address Action -> Test.Model -> Html
testView address model =
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
