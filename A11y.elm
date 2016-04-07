module A11y (..) where

import Html exposing (..)
import Html.Attributes exposing (..)


-- There's not much to this module, but since this helper function can be
-- applied to any Elm module using elm-html, it made sense to separate it out.
-- I plan to write a more extensive package of accessibility helper functions
-- to augment both elm-html and elm-css.
--
--
-- The function below adds necessary attributes for screen-reader updates
-- on state change.


liveArea : List Html.Attribute -> List Html.Attribute
liveArea additionalAttributes =
  List.append
    additionalAttributes
    [ attribute "role" "status"
    , attribute "aria-live" "polite"
    , attribute "aria-atomic" "false"
    ]
