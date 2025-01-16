#import "HeadphoneAmp.h"

// 修改SMBus寄存器定义以匹配原始实现
#define SMBUS_ADDR 0x73  // Realtek ALC代码中的地址
#define CMD_POWER 0x8B
#define CMD_GAIN  0x04
#define CMD_ENABLE 0x01

@implementation HeadphoneAmp {
    io_connect_t _connection;
}

+ (instancetype)sharedInstance {
    static HeadphoneAmp *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)initializeAmp {
    io_service_t service = IOServiceGetMatchingService(kIOMainPortDefault, 
        IOServiceMatching("AppleSMBusController"));
    if (!service) return NO;
    
    kern_return_t kr = IOServiceOpen(service, mach_task_self(), 0, &_connection);
    IOObjectRelease(service);
    if (kr != KERN_SUCCESS) return NO;

    // 按照原始Linux代码的初始化序列
    if (![self writeByte:SMBUS_ADDR command:0x01 data:CMD_POWER]) return NO;
    if (![self writeByte:SMBUS_ADDR command:0x02 data:CMD_GAIN]) return NO;
    if (![self writeByte:SMBUS_ADDR command:0x03 data:CMD_ENABLE]) return NO;
    
    return YES;
}

- (BOOL)writeByte:(UInt8)addr command:(UInt8)cmd data:(UInt8)data {
    // 实现SMBus写入
    uint64_t input[3] = {addr, cmd, data};
    return IOConnectCallMethod(_connection, 0, input, 3, 
                             NULL, 0, NULL, NULL, NULL, NULL) == KERN_SUCCESS;
}

- (BOOL)setEffect:(int)effect {
    if (effect < 0 || effect > 7) return NO;
    return [self writeByte:0x73 command:0x04 data:effect];
}

- (BOOL)setMute:(BOOL)mute {
    return [self writeByte:0x73 command:0x03 data:mute ? 0x00 : 0x01];
}

- (void)dealloc {
    if (_connection) {
        IOServiceClose(_connection);
    }
}

@end 