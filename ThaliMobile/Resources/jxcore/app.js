(function () {
  
  var _peerIdentifierKey = 'PeerIdentifier';
  
  // Peers that we know about.
  var _peers = new Array();
  
  // Peers were synchronizing with.
  var _peersSynchronizing = new Array();

  // Logs in Cordova.
  function logInCordova(text) {
    cordova('logInCordova').call(text);
  };
  
  // Gets the device name.
  function getDeviceName() {
    var deviceNameResult;
    cordova('GetDeviceName').callNative(function (deviceName) {
      logInCordova('GetDeviceName return was ' + deviceName);
      deviceNameResult = deviceName;
    });      
    return deviceNameResult;
  };
  
  // Gets the peer identifier.
  function getPeerIdentifier() {
    var peerIdentifier;
    cordova('GetKeyValue').callNative(_peerIdentifierKey, function (value) {
      peerIdentifier = value;
      if (peerIdentifier == undefined) {
        cordova('MakeGUID').callNative(function (guid) {
          peerIdentifier = guid;
          cordova('SetKeyValue').callNative(_peerIdentifierKey, guid, function (response) {
            if (!response.result) {
              alert('Failed to save the peer identifier');
            }
          });
        });
      }
    });
    return peerIdentifier;    
  };
  
  // Starts peer communications.
  function startPeerCommunications(peerIdentifier, peerName) {
    var result;
    cordova('StartPeerCommunications').callNative(peerIdentifier, peerName, function (value) {
      result = Boolean(value);
      
      logInCordova('Started peer communications');
      logInCordova('This peer is ' + peerIdentifier);

    });
    return result;
  };

  // Stops peer communications.
  function stopPeerCommunications(peerIdentifier, peerName) {
    cordova('StopPeerCommunications').callNative(function () {});
  };
      
  // Begins connecting to peer.
  function beginConnectPeer(peerIdentifier) {
    var result;
    cordova('BeginConnectPeer').callNative(peerIdentifier, function (value) {
      result = Boolean(value);
    });
    return result;
  };

  // Disconnects peer.
  function disconnectPeer(peerIdentifier) {
    var result;
    cordova('DisconnectPeer').callNative(peerIdentifier, function (value) {
      result = Boolean(value);
    });
    return result;
  };

  cordova('logInCordova').registerToNative(function (callback, args) {
    logInCordova(args[0]);
  });

  cordova('networkChanged').registerToNative(function (callback, args) {
    logInCordova(callback + ' called');
    var network = args[0];
    logInCordova(JSON.stringify(network));
    
    if (network.isReachable) {
      logInCordova('****** NETWORK REACHABLE');
    } else {
      logInCordova('****** NETWORK NOT REACHABLE');      
    }
  });
    
  // Register peerAvailabilityChanged callback.
  cordova('peerAvailabilityChanged').registerToNative(function (callback, args) {
    // Process each peer availability change.
    var peers = args[0];
    for (var i = 0; i < peers.length; i++) {
      // Get the peer.
      var peer = peers[i];

      // Log.
      logInCordova(JSON.stringify(peer));
      logInCordova('peerIdentifier: ' + peer.peerIdentifier);
      logInCordova('      peerName: ' + peer.peerName);
      logInCordova(' peerAvailable: ' + peer.peerAvailable);
      
      // Find and replace peer.
      for (var i = 0; i < _peers.length; i++) {
        if (_peers[i].peerIdentifier === peer.peerIdentifier) {
          _peers[i] = peer;
          return;
        }
      }
      
      // If we didn't find peer, add it.
      _peers.push(peer);
    }                             
  });
  
  // Register peerConnecting callback.
  cordova('peerConnecting').registerToNative(function (callback, args) {
    var peerIdentifier = args[0];
    logInCordova('    Connecting peer ' + peerIdentifier);
  });
  
  function makePeerDisconnector(peerIdentifier) {
    return function () {
      logInCordova('Peer disconnector called for ' + peerIdentifier);
      disconnectPeer(peerIdentifier);
    };
  };

  // Register peerConnected callback.
  cordova('peerConnected').registerToNative(function (callback, args) {
    var peerIdentifier = args[0];
    logInCordova('    Connected peer ' + peerIdentifier);

    if (peerName === 'DX 2') {
      setTimeout(makePeerDisconnector(peerIdentifier), 30 * 1000);      
    }
  });

  // Register peerNotConnected callback.
  cordova('peerNotConnected').registerToNative(function (callback, args) {
    var peerIdentifier = args[0];
    logInCordova('    Not connected peer ' + peerIdentifier);

    for (var i = 0; i < _peersSynchronizing.length; i++) {
      if (_peersSynchronizing[i].peerIdentifier === peerIdentifier) {
        _peersSynchronizing.splice(i, 1);
        return;
      }
    }
  });
 
  // Get the peer identifier and peer name.
  var peerIdentifier = getPeerIdentifier();
  var peerName = getDeviceName();
  
  // Start peer communications.
  startPeerCommunications(peerIdentifier, peerName);

  if (peerName === 'DX 2')
  {
    var peerSyncInterval = setInterval(function () {
      
      // If we're still synchonizing one or more peers, skip this interval.
      if (_peersSynchronizing.length != 0) {
        logInCordova('peerSync still running');      
        return;
      }
      
      // Start sync.
      logInCordova('peerSync starting');
      for (var i = 0; i < _peers.length; i++) {
        var peer = _peers[i];
  
        if (peer.peerAvailable && beginConnectPeer(peer.peerIdentifier)) {
          _peersSynchronizing.push(peer);        
          logInCordova('    Begin connect peer ' + peer.peerIdentifier);
        } else {
          logInCordova("    Can't connect peer " + peer.peerIdentifier);        
        }
      }
    }, 10000);
    
  }

  
})();
