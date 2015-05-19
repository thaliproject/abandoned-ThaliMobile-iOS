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
@property (nonatomic, readonly) NSUUID * identifier;
@property (nonatomic, readonly) NSString * name;
@property (nonatomic) BOOL connectionPossible;

// Class initializer.
- (instancetype)initWithIdentifier:(NSUUID *)peerIdentifier
                              name:(NSString *)name;

@end
