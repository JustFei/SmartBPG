//
//  BleManager.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "BleManager.h"
#import "BleDevice.h"
#import "manridyModel.h"
#import "NSStringTool.h"

static NSString *const kServiceUUID = @"000018f0-0000-1000-8000-00805f9b34fb";
static NSString *const kWriteCharacteristicUUID = @"00002af1-0000-1000-8000-00805f9b34fb";
static NSString *const kNotifyCharacteristicUUID = @"00002af0-0000-1000-8000-00805f9b34fb";

@interface BleManager ()

@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) NSMutableArray *deviceArr;

@end

@implementation BleManager


#pragma mark - Singleton
static BleManager *bleManager = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleManager = [[self alloc] init];
    });
    
    return bleManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleManager = [super allocWithZone:zone];
    });
    
    return bleManager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - action of connecting layer -连接层操作
/** 判断有没有当前设备有没有连接的 */
- (BOOL)retrievePeripherals
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"]) {
        NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
        NSArray *arr = [_myCentralManager retrievePeripheralsWithIdentifiers: @[uuid]];
        NSLog(@"当前已连接的设备%@,有%ld个",arr.firstObject ,(unsigned long)arr.count);
        if (arr.count != 0) {
            CBPeripheral *per = (CBPeripheral *)arr.firstObject;
            per.delegate = self;
            BleDevice *device = [[BleDevice alloc] initWith:per andAdvertisementData:nil andRSSI:nil];
            
            [self connectDevice:device];
            return YES;
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}

/** 扫描设备 */
- (void)scanDevice
{
    [self.deviceArr removeAllObjects];
    self.connectState = kBLEstateDisConnected;
    [_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

/** 停止扫描 */
- (void)stopScan
{
    [_myCentralManager stopScan];
}

/** 连接设备 */
- (void)connectDevice:(BleDevice *)device
{
    if (!device) {
        return;
    }
    self.isReconnect = YES;
    self.currentDev = device;
    [_myCentralManager connectPeripheral:device.peripheral options:nil];
}

/** 断开设备连接 */
- (void)unConnectDevice
{
    if (self.currentDev.peripheral) {
        [self.myCentralManager cancelPeripheralConnection:self.currentDev.peripheral];
    }
}

/** 检索已连接的外接设备 */
- (NSArray *)retrieveConnectedPeripherals
{
    return [_myCentralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}

#pragma mark - data of write -写入数据操作
#pragma mark - 统一做消息队列处理，发送
- (void)addMessageToQueue:(NSData *)message
{
    //1.写入数据
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        // wait操作-1，当别的消息进来就会阻塞，知道这条消息收到回调，signal+1后，才会继续执行。保证了消息的队列发送，保证稳定性。
        [self.currentDev.peripheral writeValue:message forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//set time
- (void)writeTimeToPeripheral:(NSDate *)currentDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSString *currentStr = [NSString stringWithFormat:@"%02ld%02ld%02ld%02ld%02ld%02ld%02ld",[comps year] % 100 ,[comps month] ,[comps day] ,[comps hour] ,[comps minute] ,[comps second] ,[comps weekday] - 1];
    //    NSLog(@"-----------weekday is %ld",(long)[comps weekday]);//在这里需要注意的是：星期日是数字1，星期一时数字2，以此类推。。。
    
    //传入时间和头，返回协议字符串
    NSString *protocolStr = [NSStringTool protocolAddInfo:currentStr head:@"00"];
    
    //写入操作
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
    NSLog(@"同步时间");
}

//get blood data
- (void)writeBPCammandToPeripheral:(WriteBPTestCammand)cammand
{
    NSString *protocolStr;
    switch (cammand) {
        case WriteBPTestCammandStart:
            protocolStr = @"0240dc01a13c";
            break;
        case WriteBPTestCammandEnd:
            protocolStr = @"02 40 dc 01 a2 3f";
            break;
        case WriteBPTestCammandCloseAudio:
            protocolStr = @"02 40 dc 01 a3 3e";
            break;
        case WriteBPTestCammandOpenAudio:
            protocolStr = @"02 40 dc 01 a4 39";
            break;
        case WriteBPTestCammandSwitchType:
            protocolStr = @"02 40 dc 01 a5 xor";
            break;
        case WriteBPTestCammandSettingType:
            protocolStr = @"02 40 dc 02 a6 num xor";
            break;
        default:
            break;
    }
    
    [self addMessageToQueue:[NSStringTool hexToBytes:protocolStr]];
}

#pragma mark - CBCentralManagerDelegate
//检查设备蓝牙开关的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message = nil;
    switch (central.state) {
        case 0:
            self.systemBLEstate = 0;
            break;
        case 1:
            self.systemBLEstate = 1;
            break;
        case 2:
        {
            self.systemBLEstate = 2;
            message = @"该设备蓝牙未授权，请检查系统设置";
        }
            break;
        case 3:
        {
            self.systemBLEstate = 3;
            message = @"该设备蓝牙未授权，请检查系统设置";
        }
            break;
        case 4:
        {
            message = NSLocalizedString(@"phoneNotOpenBLE", nil);
            self.systemBLEstate = 4;
            NSLog(@"message == %@",message);
        }
            break;
        case 5:
        {
            self.systemBLEstate = 5;
            message = NSLocalizedString(@"bleHaveOpen", nil);
        }
            break;
            
        default:
            break;
    }
    
    //[_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

//查找到正在广播的指定外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BleDevice *device = [[BleDevice alloc] initWith:peripheral andAdvertisementData:advertisementData andRSSI:RSSI];
    //当你发现你感兴趣的连接外围设备，停止扫描其他设备，以节省电能。
    if (device.deviceName != nil ) {
        if (![self.deviceArr containsObject:peripheral]) {
            [self.deviceArr addObject:peripheral];
            
            //返回扫描到的设备实例
            if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
                
                [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
            }
        }
    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    peripheral.delegate = self;
    //传入nil会返回所有服务;一般会传入你想要服务的UUID所组成的数组,就会返回指定的服务
    [peripheral discoverServices:nil];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //    NSLog(@"连接失败");
    
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidFailConnectDevice:)]) {
        [self.connectDelegate manridyBLEDidFailConnectDevice:self.currentDev];
    }
    
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectState = kBLEstateDisConnected;
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidDisconnectDevice:)]) {
        [self.connectDelegate manridyBLEDidDisconnectDevice:self.currentDev];
    }
    if (self.isReconnect) {
        NSLog(@"需要断线重连");
        [self.myCentralManager connectPeripheral:self.currentDev.peripheral options:nil];
    }else {
        self.currentDev = nil;
    }
    
}

#pragma mark - CBPeripheralDelegate
//发现到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        
        //返回特定的写入，订阅的特征即可
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kWriteCharacteristicUUID],[CBUUID UUIDWithString:kNotifyCharacteristicUUID]] forService:service];
    }
}

//获得某服务的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    //    NSLog(@"Discovered characteristic %@", service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"特征：%@", characteristic.UUID.UUIDString);
        //保存写入特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) {
            
            self.writeCharacteristic = characteristic;
            NSLog(@"保存写入特征：%@", characteristic.UUID.UUIDString);
        }
        
        //保存订阅特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotifyCharacteristicUUID]]) {
            NSLog(@"订阅特征：%@", characteristic.UUID.UUIDString);
            self.notifyCharacteristic = characteristic;
            self.connectState = kBLEstateDidConnected;
            if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidConnectDevice:)]) {
                if (self.currentDev.peripheral == peripheral) {
                    [[NSUserDefaults standardUserDefaults] setObject:peripheral.identifier.UUIDString forKey:@"peripheralUUID"];
                    [self.connectDelegate manridyBLEDidConnectDevice:self.currentDev];
                }
            }
            
            //订阅该特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

//获得某特征值变化的通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error changing notification state: %@",[error localizedDescription]);
    }else {
        NSLog(@"Success changing notification state: %d;value = %@",characteristic.isNotifying ,characteristic.value);
    }
}

//订阅特征值发送变化的通知，所有获取到的值都将在这里进行处理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"updateValue == %@",characteristic.value);
    
    [self analysisDataWithCharacteristic:characteristic.value];
    
}

//写入某特征值后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        //        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }else {
        //        NSLog(@"Success writing chararcteristic value: %@",characteristic);
    }
}

#pragma mark - 数据解析
- (void)analysisDataWithCharacteristic:(NSData *)value
{
    if ([value bytes] != nil) {
        const unsigned char *hexBytes = [value bytes];
        //命令头字段
        NSString *Byte4 = [[NSString stringWithFormat:@"%02x", hexBytes[3]] localizedLowercaseString];
        if ([Byte4 isEqualToString:@"01"]) {
            //控制指令格式
        }else if ([Byte4 isEqualToString:@"02"]) {
            
            //血压压力值数据
            NSLog(@"value.length == %ld", value.length);
            if (value.length == 7) {
                NSLog(@"压力值数据");
                NSData *bpValue = [value subdataWithRange:NSMakeRange(4, 2)];
                int bp = [NSStringTool parseIntFromData:bpValue];
                BloodModel *model = [[BloodModel alloc] init];
                model.pressureString = [NSString stringWithFormat:@"%d", bp];
                [[NSNotificationCenter defaultCenter] postNotificationName:BP_DATA object:model];
                NSLog(@"02 : %@", model);
            }
        }else if ([Byte4 isEqualToString:@"03"]) {
            
            //血压计电量数据
            if (value.length == 8) {
                NSLog(@"血压计电量数据");
                NSData *electricityValue = [value subdataWithRange:NSMakeRange(6, 1)];
                int electricity = [NSStringTool parseIntFromData:electricityValue];
                BloodModel *model = [[BloodModel alloc] init];
                model.electricity = [NSString stringWithFormat:@"%d", electricity];
                [[NSNotificationCenter defaultCenter] postNotificationName:ELECTRICITY_VALUE object:model];
                NSLog(@"03 : %@", model);
            }
        }else if ([Byte4 isEqualToString:@"0c"]) {
            //error(1c) or success(other)
            NSString *Byte5 = [[NSString stringWithFormat:@"%02x", hexBytes[4]] localizedLowercaseString];
            if ([Byte5 isEqualToString:@"1c"]) {
                //血压测量结果数据
                if (value.length == 17) {
                    NSLog(@"血压测量结果数据");
                    
                    NSString *success = [[NSString stringWithFormat:@"%02x", hexBytes[5]] localizedLowercaseString];
                    if ([success isEqualToString:@"00"]) {
                        NSData *highValue = [value subdataWithRange:NSMakeRange(5, 2)];
                        NSData *lowValue = [value subdataWithRange:NSMakeRange(7, 2)];
                        NSData *hrValue = [value subdataWithRange:NSMakeRange(11, 2)];
                        int highBp = [NSStringTool parseIntFromData:highValue];
                        int lowBp = [NSStringTool parseIntFromData:lowValue];
                        int hr = [NSStringTool parseIntFromData:hrValue];
                        BloodModel *model = [[BloodModel alloc] init];
                        model.highBloodString = [NSString stringWithFormat:@"%d", highBp];
                        model.lowBloodString = [NSString stringWithFormat:@"%d", lowBp];
                        model.bpmString = [NSString stringWithFormat:@"%d", hr];
                        model.testSuccess = YES;
                        [[NSNotificationCenter defaultCenter] postNotificationName:BP_TEST_RESULT object:model];
                        NSLog(@"0csuccess : %@", model);
                    }else {
                        BloodModel *model = [[BloodModel alloc] init];
                        model.testSuccess = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:BP_TEST_RESULT object:model];
                        NSLog(@"0cfail : %@", model);
                    }
                }
            }else {
                //error deal
                NSString *Byte13 = [[NSString stringWithFormat:@"%02x", hexBytes[12]] localizedLowercaseString];
                [[NSNotificationCenter defaultCenter] postNotificationName:BP_TEST_ERROR object:Byte13];
            }
            
        }
    }
}

#pragma mark - 通知

#pragma mark - 懒加载
- (NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    
    return _deviceArr;
}


@end

