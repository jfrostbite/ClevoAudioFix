#import <Foundation/Foundation.h>
#import "HeadphoneAmp.h"
#import <IOKit/pwr_mgt/IOPMLib.h>

void sleepWakeCallback(void *refCon, io_service_t service, natural_t messageType, void *messageArgument) {
    if (messageType == kIOMessageSystemWillSleep) {
        // 系统即将睡眠,不需要特殊处理
        IOAllowPowerChange(root_port, (long)messageArgument);
    } else if (messageType == kIOMessageSystemHasPoweredOn) {
        // 系统唤醒,重新初始化放大器
        [[HeadphoneAmp sharedInstance] initializeAmp];
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