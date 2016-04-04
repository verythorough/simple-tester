function generateDummyTest() {
  var delay = 7000 + Math.random() * 7000;
  var testPassed = Math.random() > 0.5;

  return function(callback) {
    setTimeout(function() {
      callback(testPassed);
    }, delay);
  };
}


var tests = [
  { description: "commas are rotated properly",          run: generateDummyTest() },
  { description: "exclamation points stand up straight", run: generateDummyTest() },
  { description: "run-on sentences don't run forever",   run: generateDummyTest() },
  { description: "question marks curl down, not up",     run: generateDummyTest() },
  { description: "semicolons are adequately waterproof", run: generateDummyTest() },
  { description: "capital letters can do yoga",          run: generateDummyTest() }
];

//not sure whether to put in here or inline in html:
//var el = document.getElementById('whatever');
//var simpleTester = Elm.embed(Elm.SimpleTester, el, {init info from Elm to JS ports});
//simpleTester.ports.tests.send(tests);

function runTest(test) {
  test.run ( function (result) {
      console.log(test.description + ": " + result);
    }
  )
}

function runAllTests (tests) {
  var i = 0, len = tests.length;
  for (i; i < len; i++) {
    runTest(tests[i]);
  }
}
