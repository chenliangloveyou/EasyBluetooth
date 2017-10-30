//
//  EasyPeripheral.h
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

@class EasyService ;
@class EasyPeripheral ;
@class EasyCharacteristic ;
@class EasyDescriptor ;
@class EasyCenterManager ;


typedef NS_ENUM(NSUInteger ,deviceConnectType) {
    deviceConnectTypeSuccess = 0 ,  //设备连接成功
    deviceConnectTypeFaild = 1 ,    //设备连接失败
    deviceConnectTypeFaildTimeout , //设备连接失败（原因：连接超时）
    deviceConnectTypeDisConnect ,   //设备断开连接
};


/**
 * 连接设备回调
 * perpheral 连接的设备
 * deviceConnectType 设备连接的状态
 * error 错误信息
 */
typedef void (^blueToothConnectDeviceCallback)(EasyPeripheral *perpheral,NSError *error,deviceConnectType deviceConnectType);
///**
// * 设备断开连接回调
// */
//typedef void (^blueToothDisconnectCallback)(EasyPeripheral *peripheral , NSError *error );

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
@property (nonatomic, strong,readonly) NSUUID *identifier ;
@property (nonatomic, strong,readonly) NSString *identifierString ;

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
 * 当前设备状态
 */
@property (nonatomic, assign)CBPeripheralState state ;

/**
 * 当前设备的错误信息
 */
@property (nonatomic,strong)NSError *connectErrorDescription ;

/**
 * 设备中所有的服务
 */
@property(nonatomic, strong) NSMutableArray<EasyService *> *serviceArray;

/**
 * 连接设备回调
 */
@property(nonatomic, copy) blueToothConnectDeviceCallback connectCallback ;

/**
 * 初始化操作
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral ;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(EasyCenterManager *)manager ;

/**
 * 连接一个设备
 *
 * callback           是否连接成功回调
 * disconnectCallback 当设备失去连接的时候的回调
 * timeout            连接时间，如果超过这个时间还没有连接上设备就停止连接，回调设备连接失败 (默认为5秒)
 * options            连接设备的条件
 */
- (void)connectDeviceWithCallback:(blueToothConnectDeviceCallback)callback ;

- (void)connectDeviceWithTimeOut:(NSUInteger)timeout
                        callback:(blueToothConnectDeviceCallback)callback;

- (void)connectDeviceWithTimeOut:(NSUInteger)timeout
                         Options:(NSDictionary *)options
                        callback:(blueToothConnectDeviceCallback)callback;

/**
 * 如果设备失去连接，调用此方法 再次连接设备(会保留上一次调用的参数)
 */
- (void)reconnectDevice ;

/**
 * 主动断开设备连接，（不会回调设备失去连接的方法）
 */
- (void)disconnectDevice;

/**
 * 重置设备被发现次数
 */
- (void)resetDeviceScanCount ;
/**
 * 读取设备的RSSI
 */
- (void)readDeviceRSSIWithCallback:(blueToothReadRSSICallback)callback ;

/**
 * 处理manager连接设备的结果。
 * 只有两种情况（1，连接成功。2，连接失败。）
 */
- (void)dealDeviceConnectWithError:(NSError *)error deviceConnectType:(deviceConnectType)deviceConnectType ;
//- (void)dealDeviceDisconnectWithError:(NSError *)error ;


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




