# Simple Tester
A simple tester display for unit tests, written in Elm.

## Viewing and Modifying
Simple Tester is hosted using [Github pages]https://pages.github.com/, and can be viewed immediately at https://verythorough.github.io/simple-tester.  If you fork the project as is, your version will be hosted at `https://<yourusename>,github.io/simple-tester`.

If you clone the project locally, you can run it using the `file` protocol.  Just drag `index.html` into the window of your favorite browser.

You can view and modify the HTML, CSS, and Javascript and see the changes without any special installs.  However, most of the logic is written in Elm.  If you want to modify any of that code, you'll need to [install Elm](http://elm-lang.org/install)
and use the various [Elm tools](http://elm-lang.org/get-started) to compile and test your code.

## Features
This is a simple project, but I tried to include features for maintainability, accessibility, responsiveness, and progressive enhancement.

### Maintainability
* I wrote the Elm code using the Elm Architecture model, with individual test behavior stored in an independent `Test` module, aggregated with a `TestRunner` module, initiated with `StartApp` and connected with ports in `Main`.
* Elm module code is organized neatly and clearly labeled in sections for model, update, view, and effects.
* I created a separate `A11y` module for accessibility helper functions (though there's only one so far).  This enables easy re-use by any module using elm-html.  I plan to expand this module into a published package of a11y helper functions.
* I stored Javascript to be tested in an independent `spec.js` file so that test files with similar characteristics (an object with `description` and `run` fields, where the `run` fields point to tests that return a callback to indicate success) can be switched out easily.
* I wrote the CSS to establish "site-wide" styles as well as module-specific ones.  This allows creation of new modules that naturally follow the site pattern, but don't require overrides to cancel style specific to the module.

### Accessibility
* Semantically ordered code includes proper ARIA labels on content sections and native HTML elements that automatically convey meaning.  For example, storing the test summary information in a `<caption>` element within the results `<table>` allows screen-reader applications to provide additional user cues for semantics and navigation.
* The Start button is a native `<button>` element (as opposed to a button-styled `<div>`), making it automatically keyboard accessible.
* The top status message, which changes to indicate application state, is tagged with ARIA attributes (including `aria-live`), so screen-reader users are informed as testing progresses.  These attributes are stored in a re-usable function in Elm for easy application across view elements.
* Decorative icons use standard unicode characters in dynamic pseudo elements.  User agents are inconsistent in whether they read these elements or not, but when they do, the captions are semantic.  The icons are not required for meaning, so there is no loss if a user agent does not read them.
* All site text colors sufficiently contrast with their backgrounds, allowing users with color-vision impairment (as well as outdoor users reading in bright sunlight) to easily distinguish text from background.
* Passes accessibility audits in Chrome developer tools as well as [WAVE](http://wave.webaim.org/), WebAIM's accessibility evaluation tool.

### Responsiveness
* Flexible-but-constrained width settings ensure attractive content layout at any screen width or height, without need for media queries.
* I sized fonts in em units to respond to user changes in browser default text size. (This aids accessibility as well.)

### Progressive Enhancement/Graceful Degredation
* The app is a Javascript tester, so of course it won't function without javascript, but I included a `<noscript>` message to reflect this and inform users what should be happening if Javascript were enabled.  Static portions of the page (i.e., header and footer) do not require Javascript.
* Messages indicate loading of scripts and tests, keeping users on slow connections informed of current state.
* I selected modern device system UI fonts to ensure attractive font display on a variety of devices without requiring webfont loading.
* I used some modern CSS techniques, including flex-box, dynamic pseudo-element content, and keyframe animations, to enhance the appearance, but the page is still attractive and fully functional on older browsers that don't support these properties.  In fact, even if CSS fails to load at all, the page is still functional, semantic, and neatly laid out.
* Icons are standard unicode characters. This differs from icon fonts which use the unicode private address space, as it avoids additional asset loading, and is nearly universally supported across browsers and devices. The icons are purely decorative, so in rare cases where they don't load properly, no meaning is lost.
