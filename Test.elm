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
  }


init : ( Int, String ) -> ( Model, Effects Action )
init ( id, desc ) =
  ( Model id desc
  , Effects.none
  )



-- UPDATE


type Action
  = Increment
  | Decrement


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Increment ->
      ( model, Effects.none )

    Decrement ->
      ( model, Effects.none )



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  tr
    []
    [ td [] [ text (toString (model.id) ++ model.description) ] ]
