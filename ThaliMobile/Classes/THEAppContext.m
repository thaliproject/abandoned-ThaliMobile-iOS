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

#import <TSNAtomicFlag.h>
#import <TSNPeerBluetooth.h>
#import "THEAppContext.h"
#include "jx.h"

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
    
    // Peer Bluetooth.
    TSNPeerBluetooth * _peerBluetooth;
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

// Starts communications.
- (void)startCommunications
{
    if ([_atomicFlagEnabled trySet])
    {
        [_peerBluetooth start];
    }
}

// Stops communications.
- (void)stopCommunications
{
    if ([_atomicFlagEnabled tryClear])
    {
        [_peerBluetooth stop];
    }
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
    _peerBluetooth = [[TSNPeerBluetooth alloc] initWithServiceType:serviceType
                                                    peerIdentifier:peerIdentifier
                                                          peerName:[[UIDevice currentDevice] name]];
    [_peerBluetooth setDelegate:(id<TSNPeerBluetoothDelegate>)self];

    // Done.
    return self;
}

@end
