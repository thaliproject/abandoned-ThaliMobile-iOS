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
- (instancetype)initWithIdentifier:(NSString *)identifier
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
    _lastUpdated = [[NSDate alloc] init];
    
    // Done.
    return self;
}

@end

// THEPeer (Internal) implementation.
@implementation THEPeer (Internal)
@end
