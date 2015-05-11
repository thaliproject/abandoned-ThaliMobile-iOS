// Check LICENSE file

#import <Foundation/Foundation.h>
#import "JXcore.h"
#import "JXcoreExtension.h"
#import "CDVJXcore.h"
#import "THEAppContext.h"

// Starts communications.
static void startCommunications(NSArray * array, NSString * callbackId)
{
    [[THEAppContext singleton] startCommunications];
    [JXcore callEventCallback:callbackId
                   withParams:nil];
}

// Stops communications.
static void stopsCommunications(NSArray * array, NSString * callbackId)
{
    [[THEAppContext singleton] stopCommunications];
    [JXcore callEventCallback:callbackId
                   withParams:nil];
}



static void screenInfo(NSArray * arr_, NSString * callbackId)
{
    assert ([CDVJXcore activeInstance] != nil && "JXcore instance is not ready!");

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    NSMutableArray *arr = [[NSMutableArray alloc] init];

    [arr addObject:[NSNumber numberWithDouble:screenWidth]];
    [arr addObject:[NSNumber numberWithDouble:screenHeight]];

    [JXcore callEventCallback:callbackId withParams:arr];
    
#if 0
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSMutableArray * barr = [[NSMutableArray alloc] init];
        [barr addObject:[NSNumber numberWithDouble:screenWidth]];
        [barr addObject:[NSNumber numberWithDouble:screenHeight]];
        [JXcore callEventCallback:@"brianCall" withParams:arr];
    });
#endif
}

// JXcoreExtension implementation.
@implementation JXcoreExtension

// Defines methods.
+ (void)defineMethods
{
    [JXcore addNativeMethod:startCommunications
                   withName:@"StartCommunications"];
    [JXcore addNativeMethod:stopCommunications
                   withName:@"StopCommunications"];
    [JXcore addNativeMethod:screenInfo
                   withName:@"ScreenInfo"];
}

@end