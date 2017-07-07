//
//  BleManager.h
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "manridyModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDevice.h"

@class manridyModel;

/**
 当前设备的连接状态
 kBLEstateDisConnected：未连接
 kBLEstateDidConnected：已连接
 */
typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected,
}kBLEstate;

/**
 系统蓝牙的状态
 SystemBLEStateUnknown：蓝牙装填未知
 SystemBLEStateResetting：与系统服务的连接暂时丢失，即将更新。
 SystemBLEStateUnsupported：该平台不支持蓝牙低功耗中央/客户端角色。
 SystemBLEStateUnauthorized：该应用程序未被授权使用蓝牙低功耗角色。
 SystemBLEStatePoweredOff：蓝牙当前已关机。
 SystemBLEStatePoweredOn：蓝牙目前已打开并可用。
 */
typedef enum{
    SystemBLEStateUnknown = 0,
    SystemBLEStateResetting,
    SystemBLEStateUnsupported,
    SystemBLEStateUnauthorized,
    SystemBLEStatePoweredOff,
    SystemBLEStatePoweredOn,
} SystemBLEState;

/**
 历史数据模式
 HistoryModeData：具体的历史数据
 HistoryModeCount：历史数据条数
 HistoryModeCurrent：获取当前跑步情况，此条仅仅针对跑步数据有用！！！！
 */
typedef enum : NSUInteger {
    HistoryModeData = 0,
    HistoryModeCount,
    HistoryModeCurrent,
} HistoryMode;

#pragma mark - 扫描设备协议
@protocol BleDiscoverDelegate <NSObject>

@optional
/** 扫描到设备 */
- (void)manridyBLEDidDiscoverDeviceWithMAC:(BleDevice *)device;

@end

#pragma mark - 连接协议
@protocol BleConnectDelegate <NSObject>

@optional
/** 连接成功 */
- (void)manridyBLEDidConnectDevice:(BleDevice *)device;

/** 连接失败 */
- (void)manridyBLEDidFailConnectDevice:(BleDevice *)device;

/** 断开连接 */
- (void)manridyBLEDidDisconnectDevice:(BleDevice *)device;

@end

@interface BleManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

+ (instancetype)shareInstance;

/** 当前连接的设备 */
@property (nonatomic, strong) BleDevice *currentDev;
@property (nonatomic, weak) id <BleDiscoverDelegate>discoverDelegate;
@property (nonatomic, weak) id <BleConnectDelegate>connectDelegate;
@property (nonatomic, assign) BOOL isReconnect;
@property (nonatomic, assign) kBLEstate connectState; //support add observer, abandon @readonly, don't change it anyway.
@property(nonatomic, assign,) SystemBLEState systemBLEstate;
@property (nonatomic, strong) CBCentralManager *myCentralManager;

#pragma mark - action of connecting layer -连接层操作
/** 判断有没有当前设备有没有连接的 */
- (BOOL)retrievePeripherals;

/** 扫描设备 */
- (void)scanDevice;

/** 停止扫描 */
- (void)stopScan;

/** 连接设备 */
- (void)connectDevice:(BleDevice *)device;

/** 断开设备连接 */
- (void)unConnectDevice;

/** 检索已连接的外接设备 */
- (NSArray *)retrieveConnectedPeripherals;

#pragma mark - 写入/请求相关数据
/** 设置时间 */
- (void)writeTimeToPeripheral:(NSDate *)currentDate;

/** 血压数据 */
- (void)writeBloodToPeripheral:(BloodData)bloodData;


@end
