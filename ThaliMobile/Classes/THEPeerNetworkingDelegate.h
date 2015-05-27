//
//  THEPeerNetworkingDelegate.h
//  ThaliMobile
//
//  Created by Brian Lambert on 5/13/15.
//
//

// Forward declarations.
@class THEPeerNetworking;

// THEPeerNetworkingDelegate protocol.
@protocol THEPeerNetworkingDelegate <NSObject>
@required

// Notifies the delegate that a peer was found.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
 didFindPeerIdentifier:(NSUUID *)peerIdentifier
              peerName:(NSString *)peerName;

// Notifies the delegate that a peer was lost.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
 didLosePeerIdentifier:(NSUUID *)peerIdentifier;

// Notifies the delegate that a peer is connecting.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
connectingToPeerIdentifier:(NSUUID *)peerIdentifier;

// Notifies the delegate that a peer is connected.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
connectedToPeerIdentifier:(NSUUID *)peerIdentifier;

// Notifies the delegate that a peer is not connected.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
notConnectedToPeerIdentifier:(NSUUID *)peerIdentifier;

@end
