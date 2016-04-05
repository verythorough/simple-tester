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
  | ResultStatus ( TestId, Bool )
  | DoNothing


update : Signal.Address TestId -> Action -> Model -> ( Model, Effects Action )
update startAddress action model =
  case action of
    StartTest id ->
      let
        sendTask =
          Signal.send startAddress id
            |> Task.map (\_ -> DoNothing)
      in
        ( { model | status = "Running" }
        , Effects.task <| Task.onError sendTask (\_ -> Task.succeed DoNothing)
        )

    ResultStatus ( id, hasPassed ) ->
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
        [ onClick address (StartTest model.id) ]
        [ text "Start Test" ]
    , span
        [ class "test-status" ]
        [ text (" Status: " ++ model.status) ]
    ]


viewInTable : Signal.Address Action -> Model -> Html
viewInTable address model =
  tr
    [ class ("test " ++ statusToClass model.status) ]
    [ td
        [ class "test-status" ]
        [ text model.status ]
    , td
        [ class "test-description" ]
        [ text (toString (model.id) ++ ": " ++ model.description) ]
    ]


statusToClass : String -> String
statusToClass status =
  String.toLower status
    |> String.split " "
    |> String.join "-"
