#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

@interface HeadphoneAmp : NSObject

+ (instancetype)sharedInstance;
- (BOOL)initializeAmp;
- (BOOL)setEffect:(int)effect;
- (BOOL)setMute:(BOOL)mute;

@end 