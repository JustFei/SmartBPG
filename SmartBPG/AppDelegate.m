//
//  AppDelegate.m
//  SmartBPG
//
//  Created by JustFei on 2017/6/22.
//  Copyright © 2017年 manridy.com. All rights reserved.
//

#import "AppDelegate.h"
#import "BPViewController.h"

@interface AppDelegate () < BleConnectDelegate, BleDiscoverDelegate>

{
    BOOL _isBind;
}

@property (nonatomic, strong) BleManager *myBleManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //保存 log
    [self redirectNSLogToDocumentFolder];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = WHITE_COLOR;
    
    BPViewController *vc = [[BPViewController alloc]init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    //修改title颜色和font
    [nc.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    self.window.rootViewController = nc;
    
    [BleManager shareInstance].discoverDelegate = self;
    [BleManager shareInstance].connectDelegate = self;
    //监听state变化的状态
    [[BleManager shareInstance] addObserver:self forKeyPath:@"systemBLEstate" options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    return YES;
}

#pragma mark - 监听系统蓝牙状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"监听到%@对象的%@属性发生了改变， %@", object, keyPath, change[@"new"]);
    if ([keyPath isEqualToString:@"systemBLEstate"]) {
        NSString *new = change[@"new"];
        switch (new.integerValue) {
            case 4:
            {
//                self.stateBar.text = NSLocalizedString(@"手机蓝牙未打开", nil);
                //                [self.stateBar setActionTitle:@"设置"];
                //                [self.stateBar addTarget:self action:@selector(pushToBleSet)];
//                [self.stateBar show];
            }
                break;
            case 5:
            {
                if (self.myBleManager.connectState == kBLEstateDisConnected) {
                    [self isBindPeripheral];
                }
            }
                
                break;
                
            default:
                break;
        }
    }
    //    else if ([keyPath isEqualToString:@"connectState"]) {
    //        NSString *new = change[@"new"];
    //
    //    }
}

/** 判断是否绑定 */
- (void)isBindPeripheral
{
    _isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    NSLog(@"有没有绑定设备 == %d",_isBind);
    if (_isBind) {
//        if (self.stateBar.isShowing) {
//            [self.stateBar dismiss];
//            self.stateBar = nil;
//        }
//        self.stateBar.text = @"正在连接中";
//        [self.stateBar show];
        [self connectBLE];
    }else {
//        if (self.stateBar.isShowing) {
//            [self.stateBar dismiss];
//            self.stateBar = nil;
//        }
//        self.stateBar.text = @"未绑定设备";
//        self.stateBar.actionTitle = @"绑定";
//        [self.stateBar addTarget:self action:@selector(bindAction)];
//        [self.stateBar show];
    }
}

/** 连接已绑定的设备 */
- (void)connectBLE
{
    BOOL systemConnect = [self.myBleManager retrievePeripherals];
    if (!systemConnect) {
        [self.myBleManager scanDevice];
    }
}

#pragma mark - bleConnectDelegate
- (void)manridyBLEDidConnectDevice:(BleDevice *)device
{
    //    [self.mainVc showFunctionView];
//    self.stateBar.text = @"连接成功";
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[SyncTool shareInstance] syncAllData];
//    });
}


#pragma mark - Log
- (void)redirectNSLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}
void UncaughtExceptionHandler(NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; //将调用栈拼成输出日志的字符串
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}

- (BleManager *)myBleManager
{
    if (!_myBleManager) {
        _myBleManager = [BleManager shareInstance];
        _myBleManager.discoverDelegate = self;
        _myBleManager.connectDelegate = self;
    }
    
    return _myBleManager;
}

@end
