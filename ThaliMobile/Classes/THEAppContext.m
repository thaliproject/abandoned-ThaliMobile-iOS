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
//  THEAppContext.m
//

#import <pthread.h>
#include "jx.h"
#import "JXcore.h"
#import <TSNAtomicFlag.h>
#import <TSNThreading.h>
#import "THEPeerBluetooth.h"
#import "THEPeerNetworking.h"
#import "THEAppContext.h"
#import "THEPeer.h"

// THEAppContext (THEPeerBluetoothDelegate) interface.
@interface THEAppContext (THEPeerBluetoothDelegate)
@end

// THEAppContext (THEPeerNetworkingDelegate) interface.
@interface THEAppContext (THEPeerNetworkingDelegate)
@end

// THEAppContext (Internal) interface.
@interface THEAppContext (Internal)

// Class initializer.
- (instancetype)init;

@end

// THEAppContext implementation.
@implementation THEAppContext
{
@private
    // The enabled atomic flag.
    TSNAtomicFlag * _atomicFlagEnabled;
    
    // The mutex used to protect access to things below.
    pthread_mutex_t _mutex;
    
    // The peers dictionary.
    NSMutableDictionary * _peers;

    // Peer Bluetooth.
    THEPeerBluetooth * _peerBluetooth;
    
    // Peer Networking.
    THEPeerNetworking * _peerNetworking;
}

// Singleton.
+ (instancetype)singleton
{
    // Singleton instance.
    static THEAppContext * appContext = nil;
    
    // If unallocated, allocate.
    if (!appContext)
    {
        // Allocator.
        void (^allocator)() = ^
        {
            appContext = [[THEAppContext alloc] init];
        };
        
        // Dispatch allocator once.
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, allocator);
    }
    
    // Done.
    return appContext;
}

// Defines JavaScript extensions.
- (void)defineJavaScriptExtensions
{
    // Start Peer Bluetooth native block.
    [JXcore addNativeBlock:^(NSArray *params, NSString *callbackId) {
        [self startCommunications];
        [JXcore callEventCallback:callbackId
                       withParams:nil];
    } withName:@"StartPeerCommunications"];
    
    // Stop Peer Bluetooth native block.
    [JXcore addNativeBlock:^(NSArray *params, NSString *callbackId) {
        [self stopCommunications];
        [JXcore callEventCallback:callbackId
                       withParams:nil];
    } withName:@"StopPeerCommunications"];
}

// Starts communications.
- (void)startCommunications
{
    if ([_atomicFlagEnabled trySet])
    {
        [_peerBluetooth start];
        [_peerNetworking start];
    }
}

// Stops communications.
- (void)stopCommunications
{
    if ([_atomicFlagEnabled tryClear])
    {
        [_peerBluetooth stop];
        [_peerNetworking stop];
    }
}

@end

// THEAppContext (THEPeerBluetoothDelegate) implementation.
@implementation THEAppContext (THEPeerBluetoothDelegate)

// Notifies the delegate that a peer was connected.
- (void)peerBluetooth:(THEPeerBluetooth *)peerBluetooth
didConnectPeerIdentifier:(NSUUID *)peerIdentifier
             peerName:(NSString *)peerName
{
    // Lock.
    pthread_mutex_lock(&_mutex);

    // Find the peer. If we found it, simply return.
    THEPeer * peer = [_peers objectForKey:peerIdentifier];
    if (peer)
    {
        pthread_mutex_unlock(&_mutex);
        return;
    }
    
    // Allocate and initialize the peer.
    peer = [[THEPeer alloc] initWithIdentifier:peerIdentifier
                                          name:peerName];
    [_peers setObject:peer
               forKey:peerIdentifier];

    // Fire the peerAvailabilityChanged event.
    OnMainThread(^{
        [JXcore callEventCallback:@"peerAvailabilityChanged"
                       withParams:@[[[peer identifier] UUIDString],
                                    [peer name],
                                    @(false)]];
    });

    // Unlock.
    pthread_mutex_unlock(&_mutex);
}

// Notifies the delegate that a peer was disconnected.
- (void)peerBluetooth:(THEPeerBluetooth *)peerBluetooth
didDisconnectPeerIdentifier:(NSUUID *)peerIdentifier
{
}

@end

// THEAppContext (THEPeerNetworkingDelegate) implementation.
@implementation THEAppContext (THEPeerNetworkingDelegate)

// Notifies the delegate that a peer was found.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
 didFindPeerIdentifier:(NSUUID *)peerIdentifier
              peerName:(NSString *)peerName
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Find the peer.
    THEPeer * peer = [_peers objectForKey:peerIdentifier];
    
    // If this is a new peer, add it.
    if (!peer)
    {
        // Allocate and initialize the peer, add it to the peers dictionary.
        peer = [[THEPeer alloc] initWithIdentifier:peerIdentifier
                                              name:peerName];
        [_peers setObject:peer
                   forKey:peerIdentifier];
    }
    
    // Set the connection possible flag.
    [peer setConnectionPossible:YES];

    // Fire the peerAvailabilityChanged event.
    [JXcore callEventCallback:@"peerAvailabilityChanged"
                   withParams:@[[[peer identifier] UUIDString],
                                [peer name],
                                @(true)]];

    // Unlock.
    pthread_mutex_unlock(&_mutex);
}

// Notifies the delegate that a peer was lost.
- (void)peerNetworking:(THEPeerNetworking *)peerBluetooth
 didLosePeerIdentifier:(NSUUID *)peerIdentifier
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Find the peer.
    THEPeer * peer = _peers[peerIdentifier];
    if (peer)
    {
        // Clear the connection possible flag.
        [peer setConnectionPossible:NO];

        // Fire the peerAvailabilityChanged event.
        [JXcore callEventCallback:@"peerAvailabilityChanged"
                       withParams:@[[[peer identifier] UUIDString],
                                    [peer name],
                                    @(false)]];
    }
    
    // Unlock.
    pthread_mutex_unlock(&_mutex);
}

@end

// THEAppContext (Internal) implementation.
@implementation THEAppContext (Internal)

// Class initializer.
- (instancetype)init
{
    // Initialize superclass.
    self = [super init];
    
    // Handle errors.
    if (!self)
    {
        return nil;
    }

    // Intialize.
    _atomicFlagEnabled = [[TSNAtomicFlag alloc] init];
    
    // Initialize the the mutex.
    pthread_mutex_init(&_mutex, NULL);
    _peers = [[NSMutableDictionary alloc] init];
    
    // Allocate and initialize the service type.
    NSUUID * serviceType = [[NSUUID alloc] initWithUUIDString:@"72D83A8B-9BE7-474B-8D2E-556653063A5B"];
    
    // Static declarations.
    static NSString * const PEER_IDENTIFIER_KEY = @"PeerIdentifierKey";
    
    // Obtain user defaults and see if we have a serialized peer identifier. If we do,
    // deserialize it. If not, make one and serialize it for later use.
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * peerIdentifierData = [userDefaults dataForKey:PEER_IDENTIFIER_KEY];
    if (!peerIdentifierData)
    {
        // Create a new peer identifier.
        UInt8 uuid[16];
        [[NSUUID UUID] getUUIDBytes:uuid];
        peerIdentifierData = [NSData dataWithBytes:uuid
                                            length:sizeof(uuid)];
        
        // Save the peer identifier in user defaults.
        [userDefaults setValue:peerIdentifierData
                        forKey:PEER_IDENTIFIER_KEY];
        [userDefaults synchronize];
    }
    NSUUID * peerIdentifier = [[NSUUID alloc] initWithUUIDBytes:[peerIdentifierData bytes]];
    
    // Allocate and initialize the peer Bluetooth context.
    _peerBluetooth = [[THEPeerBluetooth alloc] initWithServiceType:serviceType
                                                    peerIdentifier:peerIdentifier
                                                          peerName:[[UIDevice currentDevice] name]];
    [_peerBluetooth setDelegate:(id<THEPeerBluetoothDelegate>)self];
    
    // Allocate and initialize peer networking.
    _peerNetworking = [[THEPeerNetworking alloc] initWithServiceType:@"Thali"
                                                      peerIdentifier:peerIdentifier
                                                            peerName:[[UIDevice currentDevice] name]];
    [_peerNetworking setDelegate:(id<THEPeerNetworkingDelegate>)self];
    
    // Done.
    return self;
}

@end
