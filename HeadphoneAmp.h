#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

#define AMP_POWER_ON    0x8B
#define AMP_POWER_OFF   0x00
#define AMP_GAIN_LOW    0x04
#define AMP_GAIN_HIGH   0x07
#define AMP_ENABLE      0x01
#define AMP_DISABLE     0x00

@interface HeadphoneAmp : NSObject

+ (instancetype)sharedInstance;
- (BOOL)initializeAmp;
- (BOOL)setEffect:(int)effect;
- (BOOL)setMute:(BOOL)mute;

@end 