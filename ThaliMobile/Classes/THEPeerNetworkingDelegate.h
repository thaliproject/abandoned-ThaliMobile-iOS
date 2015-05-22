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

// Notifies the delegate that a peer was connected.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
didConnectPeerIdentifier:(NSUUID *)peerIdentifier;

// Notifies the delegate that a peer was disconnected.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
didDisconnectPeerIdentifier:(NSUUID *)peerIdentifier;

@end
