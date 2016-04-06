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

    -- StartTests ->
    --   ( { model
    --       | tests =
    --           List.map (\testModel -> Test.update StartTests testModel.id) model.tests
    --     }
    --   , Effects.none
    --   )
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
  div
    []
    [ p [] [ text model.message ]
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
    ]



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
  Test.viewInTable (Signal.forwardTo address (\_ -> DoNothing)) model



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
