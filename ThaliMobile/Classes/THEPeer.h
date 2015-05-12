//
//  THEPeer.h
//  ThaliMobile
//
//  Created by Brian Lambert on 5/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// THEPeer interface.
@interface THEPeer : NSObject

// Properties.
@property (nonatomic, readonly) NSString * identifier;
@property (nonatomic, readonly) NSString * name;
@property (atomic) NSDate * lastUpdated;

// Class initializer.
- (instancetype)initWithIdentifier:(NSString *)peerIdentifier
                              name:(NSString *)name;

@end
