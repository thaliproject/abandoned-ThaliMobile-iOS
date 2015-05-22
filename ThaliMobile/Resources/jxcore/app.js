(function () {
  // Peers that we know about.
  var _peers = {};

  // Logs in Cordova.
  function logInCordova(text) {
    cordova('logInCordova').call(text);
  };

  // Log that the app.js file was loaded.
  logInCordova('ThaliMobile app.js registering functions');
    
  cordova('networkChanged').registerToNative(function (callback, args) {
    logInCordova(callback + ' called');
    var network = args[0];
    logInCordova(JSON.stringify(network));
    
    if (network.isReachable) {
      logInCordova('****** NETWORK REACHABLE!!!');
    }                    
  });
    
  // Register peerChanged callback.
  cordova('peerChanged').registerToNative(function (callback, args) {
    logInCordova(callback + ' called');
    var peers = args[0];
             
    for (var i = 0; i < peers.length; i++) {
      var peer = peers[i];

      logInCordova(JSON.stringify(peer));
      logInCordova('peerIdentifier is ' + peer.peerIdentifier);
      logInCordova('peerName is ' + peer.peerName);
      logInCordova('state is ' + peer.state);
      
      // Set the peer.
      _peers[peer.peerIdentifier] = peer;
    }                             
                                                                                                                                          
//    // Start peer communications.
//    if (false) {
//      cordova('ConnectPeer').callNative(peer.peerIdentifier, function (result) {
//        logInCordova('ConnectPeer return code was ' + result);
//      });      
//    }

  });
 
  // Log that the app.js file was loaded.
  logInCordova('ThaliMobile app.js loaded');

  // Start peer communications.
  cordova('StartPeerCommunications').callNative(function () {
    logInCordova('Peer communications started');
  });
 
  cordova('getBuffer').registerSync(function () {
    console.log("getBuffer is called!!!");
    var buffer = new Buffer(25000);
    buffer.fill(45);
                                   
    // send back a buffer
    return buffer;
  });

//  cordova('asyncPing').registerAsync(function (message, callback) {
//    setTimeout(function () {
//      callback("Pong:" + message);
//    }, 500);
//  });

  cordova('fromJXcore').registerToNative(function (param1, param2) {
    logInCordova("************************** fromJXcore called from Objective-C");
    // this method is reachable from Java or ObjectiveC
    // OBJ-C : [JXcore callEventCallback:@"fromJXcore" withParams:arr_parms];
    // Java  : jxcore.CallJSMethod("fromJXcore", arr_params);
  });

  // calling this custom native method from JXcoreExtension.m / .java
  cordova('ScreenInfo').callNative(function (width, height) {
    console.log("Size", width, height);
  });

  cordova('ScreenBrightness').callNative(function (br) {
    console.log("Screen Brightness", br);
  });

})();
