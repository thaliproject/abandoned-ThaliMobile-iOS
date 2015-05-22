# Thali API's
This document contains information about Thali API's.

---

## Native API's Exposed to JavaScript Code
The following section contains Native API's that are exposed to JavaScript code.

---
`StartPeerCommunications(peerIdentifier, peerName)`

*Description:*

Starts peer communications.

*Params:* 

`peerIdentifier`  
`string` - Specifies the peer identifier.

`peerName`  
`string` - Specifies the peer identifier.

*Returns:*

None. 

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
`​peerChanged(peers)`

*Description:*   

Called whenever a peer changes.

*Params:*

`peers`  
`array` - A JSON array containing a `peer` object for each peer that changed

Each `peer` object contains the following properties:

>`peerIdentifier`  
>`string` - The UUID identifier of the peer.
>
>`peerName`  
>`string` - The peer name.
>
>`state`  
>`string` - The peer state.
>
>>Valid states are:
>>
>>`Unavailable`  
>>The peer is unavailable. (Calling ConnectPeer will fail.)
>>
>>`Available`  
>>The peer is available. (Calling ConnectPeer may succeed.)
>>
>>`Connecting`  
>>After a call to ConnectPeer, the state will change to Connecting while the
>>connection is being established. It will then  change to Connected, if the
>>connection was successfully established. If the connection could not be
>> established, the state will change to either Unavailable or Available the next
>> time peerChanged is called, depending on the peer's availability.
>>
>>`Connected`  
>>After a call to ConnectPeer, the state will change to Connected.
>
>Example:
>
>```
>[{
>  "peerIdentifier": "F50F4805-A2AB-4249-9E2F-4AF7420DF5C7",
>  "peerName": "Her Phone",
>  "state": "Available"
>},
{
>  "peerIdentifier": "1B378E14-0B99-4E16-8275-562AF66BE8D9",
>  "peerName": "His Phone",
>  "state": "Unavailable"
>}]
>```

*Returns:*

None. 

*Notes:* 

When a peer is first discovered, `peerChanged` is called with the appropriate state.
Each time the state of a peer changes, `peerChanged` will be called to notify the 
application.

On some systems, `peerChanged` will be called immediately when the state of a peer 
changes. On other systems, there may be a significant period of time between
`peerChanged` callbacks.

---
End of document.
