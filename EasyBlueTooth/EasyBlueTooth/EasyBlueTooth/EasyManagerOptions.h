//
//  EasyManagerOptions.h
//  EasyBlueTooth
//
//  Created by nf on 2016/8/25.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EasyManagerOptions : NSObject

/**
 * 蓝牙所有操作所在的线程。如果不传，将会在主线程上操作。
 * note：如果传入线程，那么返回数据的UI操作需要放到主线程上
 */
@property (nonatomic,strong)dispatch_queue_t managerQueue ;

/**
 * initWithDelegate:queue:options: 方法参数
 *
 * CBCentralManagerOptionShowPowerAlertKey  默认为NO，系统当蓝牙关闭时是否弹出一个警告框
 * CBCentralManagerOptionRestoreIdentifierKey 系统被杀死，重新恢复centermanager的ID
 */
@property (nonatomic,strong)NSDictionary *managerDictionary ;

/**
 * scanForPeripheralsWithServices:options: 方法参数
 *
 * CBCentralManagerScanOptionAllowDuplicatesKey  默认为NO，过滤功能是否启用，每次寻找都会合并相同的peripheral。如果设备YES的话每次都能接受到来自peripherals的广播包数据。
 * CBCentralManagerScanOptionSolicitedServiceUUIDsKey  想要扫描的服务的UUID，以一个数组的形式存在。扫描的时候只会扫描到包含这些UUID的设备。
 */
@property (nonatomic,strong)NSDictionary *scanOptions ;


@property (nonatomic,strong)NSArray *scanServiceArray ;//连接设备所需的服务.

/**
 * connectPeripheral:options: 方法中的参数
 * CBConnectPeripheralOptionNotifyOnConnectionKey 默认为NO，APP被挂起时，这时如果连接到peripheral时，是否要给APP一个提示框。
 * CBConnectPeripheralOptionNotifyOnDisconnectionKey 默认为NO，APP被挂起时，恰好在这个时候断开连接，要不要给APP一个断开提示。
 * CBConnectPeripheralOptionNotifyOnNotificationKey  默认为NO，APP被挂起时，是否接受到所有的来自peripheral的包都要弹出提示框。
 *
 */
@property (nonatomic,strong)NSDictionary *connectOptions ;//连接设备时所带的条件

/*
 * 扫描所需时间。默认为永久
 */
@property (nonatomic,assign)NSUInteger scanTimeOut ;

/*
 * 连接设备最大时长 默认为5秒
 */
@property (nonatomic,assign)NSUInteger connectTimeOut ;

/**
 * 断开连接后重新连接
 */
@property (nonatomic,assign)BOOL autoConnectAfterDisconnect ;


- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue
                   managerDictionary:(NSDictionary *)managerDictionary ;

- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue
                   managerDictionary:(NSDictionary *)managerDictionary
                         scanOptions:(NSDictionary *)scanOptions
                    scanServiceArray:(NSArray *)scanServiceArray ;

- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue
                   managerDictionary:(NSDictionary *)managerDictionary
                         scanOptions:(NSDictionary *)scanOptions
                    scanServiceArray:(NSArray *)scanServiceArray
                      connectOptions:(NSDictionary *)connectOptions;
@end













