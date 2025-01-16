#import "HeadphoneAmp.h"

// SMBus registers
#define TRANSMIT_SLAVE_ADDR_REG 0x4
#define HOST_CMD_REG 0x3  
#define HOST_DATA_REG 0x5

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
    // 通过IOKit找到SMBus控制器
    io_service_t service = IOServiceGetMatchingService(kIOMainPortDefault, 
        IOServiceMatching("AppleSMBusController"));
    if (!service) return NO;
    
    // 打开连接
    kern_return_t kr = IOServiceOpen(service, mach_task_self(), 0, &_connection);
    IOObjectRelease(service);
    if (kr != KERN_SUCCESS) return NO;

    // 初始化放大器
    [self writeByte:0x73 command:0x01 data:0x8B];
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