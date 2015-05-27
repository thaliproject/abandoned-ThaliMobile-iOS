# Thali API's
This document contains information about Thali API's.

---

## Native API Functions Exposed to JavaScript Code
The following section contains Native API's that are exposed to JavaScript code.

---
`GetDeviceName()`  
*This is an optional API function that is used for scaffolding on iOS at this time.*

*Description:*

Gets the device name.

*Params:* 

None.

*Returns:*

`string`  
The device name.

*Notes:*

On iOS, this returns `[[UIDevice currentDevice] name]`.

---
`MakeGUID()`  
*This is an optional API function that is used for scaffolding on iOS at this time.*

*Description:*

Returns a new GUID.

*Params:* 

None.

*Returns:*

`string`  
The new GUID.

*Notes:*

On iOS, this returns `[[NSUUID UUID] UUIDString]`.

---
`GetKeyValue(key)`  
*This is an optional API function that is used for scaffolding on iOS at this time.*

*Description:*

Gets the value of the specified key.

*Params:* 

`key`  
`string` - The key to get.

*Returns:*

`string`  
The key value, if successful; otherwise, `undefined`.

*Notes:*

None.

---
`SetKeyValue(key, value)`  
*This is an optional API function that is used for scaffolding on iOS at this time.*

*Description:*

Sets the value of the specified key.

*Params:* 

`key`
`string` - The key to set.

`value`
`string` - The value for the key.

*Returns:*

`string`  
The key value, if successful; otherwise, `undefined`.

*Notes:*

None.

---
`StartPeerCommunications(peerIdentifier, peerName)`

*Description:*

Starts peer communications.

*Params:* 

`peerIdentifier`  
`string` - Specifies the peer identifier. The `peerIdentifier` uniquely identifies a peer to
other peers. 

Example:

> BEEFCAFE-BEEF-CAFE-BEEF-CAFEBEEFCAFE

`peerName`  
`string` - Specifies the peer name. The `peerName` should be a short name describing the peer.
it is used for debugging and trans purposes.

*Returns:*

`boolean`  
`true` if successfull; otherwise, `false`.


*Notes:* 

For iOS this means we turn on BTLE advertisement and scanning. It also means that we
start the Multipeer Connectivity Framework Advertiser and Browser.

Other platforms will use other techniques.

---
`StopPeerCommunications()`  

*Description:*   

Stops peer communications. 

*Params:* 

None.

*Returns:*

None. 

*Notes:* 

For iOS this means we turn off BTLE advertisement and scanning. It also means that we
stop the Multipeer Connectivity Framework Advertiser and Browser.

Other platforms will use other techniques.

---
`boolean BeginConnectPeer(peerIdentifier)`  

*Description:*   

Begins an attempt to connect to the peer with the specified peer identifier.

*Params:* 

`peerIdentifier`  
`string` - Specifies the peer identifier.

*Returns:*

`boolean`  
`true` if a connection attempt was successfully started; otherwise, `false`.

*Notes:* 

Upon successful return, the underlying system will attempt to connect to the peer 
with the specified peer identifier. 

The `peerChanged` callback will be called when the state of a peer has changed. See
below.

---
`boolean DisconnectPeer(peerIdentifier)`

*Description:*   

Disconnect from the peer with the specified peer identifier.

*Params:* 

`peerIdentifier`  
`string` - Specifies the peer identifier.

*Returns:*

`boolean`  
`true` if the connection was disconnected; otherwise, `false`.

*Notes:* 

The `peerChanged` callback will be called when the state of a peer has changed. See
below.

---

## JavaScript Callbacks Called from Native Code
The following section contains JaavScript callbacks that are called by native code.

---
`networkChanged(network)`

*Description:*   

Called whenever a network change occurs.

*Params:*

`network`  
`object` - JSON object containing the following properties:

>`isReachable`  
>`boolean` - A value which indicates whether the network is currently reachable.
>
>`isWiFi`  
>`boolean` - A value that indicates whether the network is currently reachable via Wi-Fi. This property may be omitted when the `isReachable` property is false.

Examples:

```
{
  "isReachable": true,
  "isWiFi": true
}

{
  "isReachable": false
}
```

---
`​peerAvailabilityChanged(peers)`

*Description:*   

Called whenever a peer changes.

*Params:*

`peers`  
`array` - A JSON array containing a `peer` object for each peer that changed

Each `peer` object contains the following properties:

>`peerIdentifier`  
>`string` - The peer identifier.
>
>`peerName`  
>`string` - The peer name.
>
>`peerAvailable`  
>`boolean` - A value which indicates whether the peer is available.
>>
>>`false`  
>>The peer is unavailable. Calling `BeginConnectPeer` will fail.
>>
>>`true`  
>>The peer is available. Calling `BeginConnectPeer` may succeed.
>
>Examples:
>
>```
>[{
>  "peerIdentifier": "F50F4805-A2AB-4249-9E2F-4AF7420DF5C7",
>  "peerName": "Her Phone",
>  "peerAvailable": true
>},
{
>  "peerIdentifier": "1B378E14-0B99-4E16-8275-562AF66BE8D9",
>  "peerName": "His Phone",
>  "peerAvailable": false
>}]
>```

*Returns:*

None. 

*Notes:* 

When a peer is first discovered, `peerChanged` is called with the appropriate state.
Each time the state of a peer changes, `peerChanged` will be called to notify the 
application of the change.

On some systems, `peerChanged` will be called immediately when the state of a peer 
changes. On other systems, where polling is being used to detect the state of nearby peers,
there may be a significant period of time between `peerChanged` callbacks.

---
`​peerConnecting(peerIdentifier)`

*Description:*   

Called when a peer is connecting.

*Params:*

`peerIdentifier`  
`string` - The peer identifier.

*Returns:*

None. 

*Notes:* 

After 'BeginConnectPeer' is called and successfully returns, `peerConnecting` will be called
to indicate that the connection to the peer is being established.

---
`​peerConnected(peerIdentifier)`

*Description:*   

Called when a peer is connected.

*Params:*

`peerIdentifier`  
`string` - The peer identifier.

*Returns:*

None. 

*Notes:* 

None.

---
`​peerNotConnected(peerIdentifier)`

*Description:*   

Called when a peer is not connected.

*Params:*

`peerIdentifier`  
`string` - The peer identifier.

*Returns:*

None. 

*Notes:* 

`peerNotConnected` is called to indicate that a peer is not connected. 

This may occur immediately after a call to `BeginConnectPeer`. It may occur after `peerConnecting`
has been called to indicate that the connection could not be established.

---
End of document.
