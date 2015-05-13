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

// Notifies the delegate that data was received.
- (void)peerNetworking:(THEPeerNetworking *)peerNetworking
        didReceiveData:(NSData *)data;

@end
