#import <Foundation/Foundation.h>
#import "HeadphoneAmp.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>

// 声明全局变量
static io_connect_t root_port;

void sleepWakeCallback(void *refCon, io_service_t service, natural_t messageType, void *messageArgument) {
    if (messageType == kIOMessageSystemWillSleep) {
        // 睡眠前可能需要保存状态
        IOAllowPowerChange(root_port, (long)messageArgument);
    } else if (messageType == kIOMessageSystemHasPoweredOn) {
        // 添加重试逻辑
        int retries = 3;
        while (retries--) {
            if ([[HeadphoneAmp sharedInstance] initializeAmp]) {
                break;
            }
            [NSThread sleepForTimeInterval:0.5];
        }
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 初始化放大器
        HeadphoneAmp *amp = [HeadphoneAmp sharedInstance];
        if (![amp initializeAmp]) {
            NSLog(@"Failed to initialize headphone amplifier");
            return 1;
        }
        
        // 注册系统睡眠/唤醒通知
        IONotificationPortRef notifyPortRef;
        io_object_t notifierObject;
        root_port = IORegisterForSystemPower(NULL, &notifyPortRef, sleepWakeCallback, &notifierObject);
        
        if (!root_port) {
            NSLog(@"Failed to register for system power notifications");
            return 1;
        }
        
        // 添加通知端口到运行循环
        CFRunLoopAddSource(CFRunLoopGetCurrent(),
                          IONotificationPortGetRunLoopSource(notifyPortRef),
                          kCFRunLoopDefaultMode);
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
} 