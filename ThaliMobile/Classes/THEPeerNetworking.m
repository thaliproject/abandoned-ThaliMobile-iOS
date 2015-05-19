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
//  THEPeerNetworking.m
//

#import <pthread.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "THEPeerNetworking.h"

// Static declarations.
static NSString * const PEER_ID_KEY     = @"ThaliPeerID";
static NSString * const PEER_IDENTIFIER = @"PeerIdentifier";
static NSString * const PEER_NAME       = @"PeerName";

// THEPeerDescriptor interface.
@interface THEPeerDescriptor : NSObject

// Properties.
@property (nonatomic) MCPeerID * peerID;
@property (nonatomic) NSUUID * peerIdentifier;
@property (nonatomic) NSString * peerName;

// Class initializer.
- (instancetype)initWithPeerID:(MCPeerID *)peerId
                peerIdentifier:(NSUUID *)peerIdentifier
                      peerName:(NSString *)peerName;

@end

// THEPeerDescriptor implementation.
@implementation THEPeerDescriptor
{
@private
}

// Class initializer.
- (instancetype)initWithPeerID:(MCPeerID *)peerID
                peerIdentifier:(NSUUID *)peerIdentifier
                      peerName:(NSString *)peerName
{
    // Initialize superclass.
    self = [super init];
    
    // Handle errors.
    if (!self)
    {
        return nil;
    }
    
    // Initialize.
    _peerID = peerID;
    _peerIdentifier = peerIdentifier;
    _peerName = peerName;
    
    // Done.
    return self;
}

@end

// THEPeerNetworking (MCNearbyServiceAdvertiserDelegate) interface.
@interface THEPeerNetworking (MCNearbyServiceAdvertiserDelegate) <MCNearbyServiceAdvertiserDelegate>
@end

// THEPeerNetworking (MCNearbyServiceBrowserDelegate) interface.
@interface THEPeerNetworking (MCNearbyServiceBrowserDelegate) <MCNearbyServiceBrowserDelegate>
@end


// THEPeerNetworking (MCSessionDelegate) interface.
@interface THEPeerNetworking (MCSessionDelegate) <MCSessionDelegate>
@end

// THEPeerNetworking (Internal) interface.
@interface THEPeerNetworking (Internal)
@end

// THEPeerNetworking implementation.
@implementation THEPeerNetworking
{
@private
    // The service type.
    NSString * _serviceType;
    
    // The peer identifier.
    NSUUID * _peerIdentifier;
    
    // The peer name.
    NSString * _peerName;
    
    // The peer ID.
    MCPeerID * _peerID;
    
    // The session.
    MCSession * _session;
    
    // The nearby service advertiser.
    MCNearbyServiceAdvertiser * _nearbyServiceAdvertiser;
    
    // The nearby service browser.
    MCNearbyServiceBrowser * _nearbyServiceBrowser;
    
    // Mutex used to synchronize accesss to the things below.
    pthread_mutex_t _mutex;

    // The peers dictionary.
    NSMutableDictionary * _peers;
}

// Class initializer.
- (instancetype)initWithServiceType:(NSString *)serviceType
                     peerIdentifier:(NSUUID *)peerIdentifier
                           peerName:(NSString *)peerName
{
    // Initialize superclass.
    self = [super init];
    
    // Handle errors.
    if (!self)
    {
        return nil;
    }
    
    // Initialize.
    _serviceType = serviceType;
    _peerIdentifier = peerIdentifier;
    _peerName = peerName;
    
    // Initialize
    pthread_mutex_init(&_mutex, NULL);
    
    // Allocate and initialize the peers dictionary. It contains a THEPeerDescriptor for
    // every peer we are aware of.
    _peers = [[NSMutableDictionary alloc] init];

    // Done.
    return self;
}

// Starts peer networking.
- (void)start
{
    // Obtain user defaults and see if we have a serialized MCPeerID. If we do, deserialize it. If not, make one
    // and serialize it for later use. If we don't serialize and reuse the MCPeerID, we'll see duplicates
    // of this peer in sessions.
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [userDefaults dataForKey:PEER_ID_KEY];
    if ([data length])
    {
        // Deserialize the MCPeerID.
        _peerID = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        // Allocate and initialize a new MCPeerID.
        _peerID = [[MCPeerID alloc] initWithDisplayName:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] name]]];
        
        // Serialize and save the MCPeerID in user defaults.
        data = [NSKeyedArchiver archivedDataWithRootObject:_peerID];
        [userDefaults setValue:data
                        forKey:PEER_ID_KEY];
        [userDefaults synchronize];
    }
    
    // Allocate and initialize the session.
    _session = [[MCSession alloc] initWithPeer:_peerID
                              securityIdentity:nil
                          encryptionPreference:MCEncryptionRequired];
    [_session setDelegate:(id<MCSessionDelegate>)self];
    
    // Allocate and initialize the nearby service advertizer.
    _nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID
                                                                 discoveryInfo:@{PEER_IDENTIFIER:   [_peerIdentifier UUIDString],
                                                                                 PEER_NAME:         _peerName}
                                                                   serviceType:_serviceType];
    [_nearbyServiceAdvertiser setDelegate:(id<MCNearbyServiceAdvertiserDelegate>)self];
    
    // Allocate and initialize the nearby service browser.
    _nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID
                                                             serviceType:_serviceType];
    [_nearbyServiceBrowser setDelegate:(id<MCNearbyServiceBrowserDelegate>)self];
    
    // Start advertising this peer and browsing for peers.
    [_nearbyServiceAdvertiser startAdvertisingPeer];
    [_nearbyServiceBrowser startBrowsingForPeers];
    
    // Log.
    NSLog(@"THEPeerNetworking initialized peer %@", [_peerID displayName]);
}

// Stops peer networking.
- (void)stop
{
    // Stop advertising this peer and browsing for peers.
    [_nearbyServiceAdvertiser stopAdvertisingPeer];
    [_nearbyServiceBrowser stopBrowsingForPeers];
    
    // Disconnect from the session.
    [_session disconnect];
    
    // Clean up.
    _nearbyServiceAdvertiser = nil;
    _nearbyServiceBrowser = nil;
    _session = nil;
    _peerID = nil;
}

@end

// THEPeerNetworking (MCNearbyServiceAdvertiserDelegate) implementation.
@implementation THEPeerNetworking (MCNearbyServiceAdvertiserDelegate)

// Notifies the delegate that an invitation to join a session was received from a nearby peer.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL accept, MCSession * session))invitationHandler
{
    // Log.
    NSLog(@"%@ sent invitation", [peerID displayName]);
    
    // Accept the invitation.
    invitationHandler(YES, _session);
    
    // Log.
    NSLog(@"%@ invitation accepted", [peerID displayName]);
}

// Notifies the delegate that advertisement failed.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"%@ did not start advertising: %@", [_peerID displayName], [error localizedDescription]);
}

@end

// THEPeerNetworking (MCNearbyServiceBrowserDelegate) implementation.
@implementation THEPeerNetworking (MCNearbyServiceBrowserDelegate)

// Notifies the delegate that a peer was found.
- (void)browser:(MCNearbyServiceBrowser *)browser
      foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary *)info
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    THEPeerDescriptor * peerDescriptor = [[THEPeerDescriptor alloc]initWithPeerID:peerID
                                                                   peerIdentifier:[[NSUUID alloc] initWithUUIDString:info[PEER_IDENTIFIER]]
                                                                         peerName:info[PEER_NAME]];
    
    _peers[peerID] = peerDescriptor;

    // Unlock.
    pthread_mutex_unlock(&_mutex);
    
    if ([[self delegate] respondsToSelector:@selector(peerNetworking:didFindPeerIdentifier:peerName:)])
    {
        [[self delegate] peerNetworking:self
                  didFindPeerIdentifier:[peerDescriptor peerIdentifier]
                               peerName:[peerDescriptor peerName]];
    }

    
//    // If it's not this local peer, invite the peer to the session.
//    if (![[_peerID displayName] isEqualToString:[peerID displayName]])
//    {
//        // Log.
//        NSLog(@"%@ was found", [peerID displayName]);
//        
//        // Invite the peer to the session.
//        [_nearbyServiceBrowser invitePeer:peerID
//                                toSession:_session
//                              withContext:nil
//                                  timeout:30];
//        
//        // Log.
//        NSLog(@"%@ invited", [peerID displayName]);
//    }
}

// Notifies the delegate that a peer was lost.
- (void)browser:(MCNearbyServiceBrowser *)browser
       lostPeer:(MCPeerID *)peerID
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    THEPeerDescriptor * peerDescriptor = _peers[peerID];

    if (!peerDescriptor)
    {
        pthread_mutex_unlock(&_mutex);
        return;
    }
    
    [_peers removeObjectForKey:peerID];
    
    // Unlock.
    pthread_mutex_unlock(&_mutex);
    
    if ([[self delegate] respondsToSelector:@selector(peerNetworking:didLosePeerIdentifier:)])
    {
        [[self delegate] peerNetworking:self
                  didLosePeerIdentifier:[peerDescriptor peerIdentifier]];
    }
}

// Notifies the delegate that the browser failed to start browsing for peers.
- (void)browser:(MCNearbyServiceBrowser *)browser
didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"%@ did not start browsing for peers: %@", [_peerID displayName], [error localizedDescription]);
}

@end

// THEPeerNetworking (MCSessionDelegate) implementation.
@implementation THEPeerNetworking (MCSessionDelegate)

// Notifies the delegate that the local peer receieved data from a nearby peer.
- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    // Log.
    NSLog(@"%@ sent %lu bytes", [peerID displayName], [data length]);
    
//    // Notify.
//    if ([[self delegate] respondsToSelector:@selector(peerNetworking:didReceiveData:)])
//    {
//        [[self delegate] peerNetworking:self didReceiveData:data];
//    }
}

// Notifies the delegate that the local peer started receiving a resource from a nearby peer.
- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress
{
    NSLog(@"%@ started sending %@", [peerID displayName], resourceName);
}

// Notifies the delegate that the local peer finished receiving a resource from a nearby peer.
- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error
{
    NSLog(@"%@ finished sending %@ [%@]", [peerID displayName], resourceName, localURL);
}

// Notifies the delegate that the local peer received a stream from a nearby peer.
- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@ sent stream %@", [peerID displayName], streamName);
}

// Notifies the delegate that the state of a nearby peer changed.
- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state
{
    // Log.
    NSString * stateValue;
    switch (state)
    {
        case MCSessionStateNotConnected:
            stateValue = @"not connected";
            break;
            
        case MCSessionStateConnecting:
            stateValue = @"connecting";
            break;
            
        case MCSessionStateConnected:
            stateValue = @"connected";
            break;
    }
    NSLog(@"%@ %@", [peerID displayName], stateValue);
    NSArray * connectedPeers = [_session connectedPeers];
    NSLog(@"------------ %lu Connected Peers ------------", [connectedPeers count]);
    for (MCPeerID * connectedPeerID in [_session connectedPeers])
    {
        if (![[connectedPeerID displayName] isEqualToString:[_peerID displayName]])
        {
            NSLog(@"    %@ connected", [connectedPeerID displayName]);
        }
    }
}

// Notifies the delegate to validate the client certificate provided by a nearby peer when a connection is first established.
- (void)session:(MCSession *)session
didReceiveCertificate:(NSArray *)certificate
       fromPeer:(MCPeerID *)peerID
certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    NSLog(@"%@ sent certificate",  [peerID displayName]);
    
    certificateHandler(YES);
    
    NSLog(@"%@ certificate accepted",  [peerID displayName]);
}

@end

// THEPeerNetworking (Internal) implementation.
@implementation THEPeerNetworking (Internal)
@end
