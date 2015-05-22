//
//  THEPeer.m
//  ThaliMobile
//
//  Created by Brian Lambert on 5/12/15.
//
//

#import "THEPeer.h"

// THEPeer (Internal) interface.
@interface THEPeer (Internal)
@end

// THEPeer implementation.
@implementation THEPeer
{
@private
}

// Class initializer.
- (instancetype)initWithIdentifier:(NSUUID *)identifier
                              name:(NSString *)name
{
    // Initialize superclass.
    self = [super init];
    
    // Handle errors.
    if (!self)
    {
        return nil;
    }
    
    // Initialize.
    _identifier = identifier;
    _name = name;
    
    // Done.
    return self;
}

// Converts THEPeer to JSON.
- (NSString *)JSON
{
    NSString * state;
    switch ([self state])
    {
        case THEPeerStateUnavailable:
            state = @"Unavailable";
            break;
            
        case THEPeerStateAvailable:
            state = @"Available";
            break;
            
        case THEPeerStateConnecting:
            state = @"Connecting";
            break;
            
        case THEPeerStateConnected:
            state = @"Connected";
            break;
            
        default:
            state = @"null";
            break;
    }
    
    return [NSString stringWithFormat:@"[ { \"peerIdentifier\": \"%@\", \"peerName\": \"%@\", \"state\": \"%@\" } ]",
            [[self identifier] UUIDString],
            [self name],
            state];
}

@end

// THEPeer (Internal) implementation.
@implementation THEPeer (Internal)
@end
