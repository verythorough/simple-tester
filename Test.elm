module Test (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects)


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
  { id : Int
  , description : String
  , status : String
  }


initialModel : ( Int, String ) -> Model
initialModel ( id, desc ) =
  { id = id
  , description = desc
  , status = "Not Started Yet"
  }



-- UPDATE


type Action
  = StartTest Int
  | TestResult


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    StartTest id ->
      ( { model | status = "Running" }, Effects.none )

    TestResult ->
      ( model, Effects.none )



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ button [ onClick address (StartTest model.id) ] [ text "Start" ]
    , span [] [ text model.status ]
    , span [] [ text model.description ]
    ]
