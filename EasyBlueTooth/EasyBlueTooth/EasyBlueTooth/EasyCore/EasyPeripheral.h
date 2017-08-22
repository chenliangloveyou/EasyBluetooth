//
//  EasyPeripheral.h
//  EasyBlueTooth
//
//  Created by nf on 2017/8/14.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

@class EasyService ;
@class EasyPeripheral ;
@class EasyCharacteristic ;
@class EasyDescriptor ;
@class EasyCenterManager ;

/**
   * 当前设备状态发生改变 (最需要处理的是断开连接的时候)
   */
typedef void (^blueToothDeviceStateChangedCallback)(EasyPeripheral *perpheral , CBPeripheralState state);

/*
   * 连接设备的回调
   */
typedef void (^blueToothCollectDeviceCallback)(EasyPeripheral *peripheral , NSError *error);

/**
   * 读取RSSI回调，次回掉之后会一次返回结果
   */
typedef void (^blueToothReadRSSICallback)(EasyPeripheral *peripheral , NSNumber *RSSI , NSError *error);

/**
   * 寻找设备中的服务回掉
   */
typedef void (^blueToothFindServiceCallback)(EasyPeripheral *peripheral , NSArray<EasyService *> *serviceArray , NSError * error);



@interface EasyPeripheral : NSObject

/**
   * 设备名称
   */
@property (nonatomic, strong ,readonly) NSString *name;

/**
   * 设备的唯一ID
   */
@property(nonatomic, strong,readonly) NSUUID *identifier ;

/**
   * 系统提供出来的当前设备
   */
@property (nonatomic, strong) CBPeripheral *peripheral;

/**
   * 设备当前的中心管理者
   */
@property (nonatomic, weak ,readonly) EasyCenterManager *centerManager;

/**
   * 设备被扫描到的次数
   */
@property (nonatomic,assign)NSUInteger deviceScanCount ;

/**
   * 设备的rssi
   */
@property(nonatomic, strong) NSNumber *RSSI;

/**
   * 设备当前的广播数据
   */
@property (nonatomic,strong)NSDictionary *advertisementData ;
/**
   * 当前是否连接成功
   */
@property (nonatomic ,assign ,readonly) BOOL isConnected;

/**
   * rssi 读取时间间隔
   */
//@property (nonatomic, assign) NSTimeInterval rssiReadInterval;

/**
   *当前设备状态
   */
@property (nonatomic, assign)CBPeripheralState state ;

/**
   * 设备的当前连接状态（可用KVO监听其值的变化）
   */
@property(nonatomic, copy) blueToothDeviceStateChangedCallback stateChangedCallback;

/**
   * 设备中所有的服务
   */
@property(nonatomic, strong) NSMutableArray<EasyService *> *serviceArray;


/**
   * 初始化操作
   */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral ;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(EasyCenterManager *)manager ;

/**
   * 连接一个设备
   */
- (void)connectDevice;

- (void)connectDeviceWithCallback:(blueToothCollectDeviceCallback)callback ;

- (void)connectDeviceWithOptions:(NSDictionary *)options
                        callback:(blueToothCollectDeviceCallback)callback ;


/**
   * 断开连接 不会回调上面 设备断开的回调
   */
- (void)disconnectDevice;

/**
   * 读取设备的RSSI
   */
- (void)readDeviceRSSIWithCallback:(blueToothReadRSSICallback)callback ;

/**
   * 处理manager的连接结果
   */
- (void)dealManagerConnectDeviceWithError:(NSError *)error;

/**
   * 处理断开连接结果（自动断开连接，非主动断开连接）
   */
- (void)dealManagerDisconnectDeviceWithError:(NSError *)error;

/**
   * 设备中所有的服务
   */
- (EasyService *)searchServiceWithService:(CBService *)service ;


/**
   * 查找设备中的所有服务
   * uuidArray 过滤查找的条件
   */
- (void)discoverAllDeviceServiceWithCallback:(blueToothFindServiceCallback)callback ;

- (void)discoverDeviceServiceWithUUIDArray:(NSArray<CBUUID *> *)uuidArray
                                  callback:(blueToothFindServiceCallback)callback;




@end




