//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Microsoft
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  ThaliMobile
//  thali_mobile.js
//

(function () {
  // Log in Cordova.
  function logInCordova(x) {
    var logging = document.getElementById('logEntries');
    if (logging) {
      var logEntryDiv = document.createElement('div');
      logEntryDiv.className = 'logEntry';
      logEntryDiv.innerHTML = x;
      logging.appendChild(logEntryDiv);
    }
  }

  function jxcore_ready() {
    // calling a method from JXcore (app.js)
    jxcore('asyncPing').call('Hello', function (ret, err) {
      // register getTime method from jxcore (app.js)
      var getBuffer = jxcore("getBuffer");

      getBuffer.call(function (bf, err) {
        var arr = new Uint8Array(bf);
        logInCordova("Buffer size:" + arr.length + " - first item: " + arr[0]);
      });
    });
  }


  var jxcoreLoadedInterval = setInterval(function () {
    // HACK Repeat until jxcore is defined. 
    if (typeof jxcore == 'undefined') {
      return;
    }

    // Stop interval.
    clearInterval(jxcoreLoadedInterval);

    // Set the ready function.
    jxcore.isReady(function () {
      // Log that JXcore is ready.
      logInCordova('JXcore reports ready.');

      jxcore('logger').register(logInCordova);

      logInCordova('Loading app.js');
      jxcore('app.js').loadMainFile(function (ret, err) {
        if (err) {
          alert("Error!!!" + err);
        } else {
          logInCordova('Loaded');
          jxcore_ready();
        }
      });
    });
  }, 10);
})();
