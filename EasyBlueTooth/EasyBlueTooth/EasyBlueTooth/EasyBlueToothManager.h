//
//  EasyBlueToothManager.h
//  EasyBlueTooth
//
//  Created by nf on 2016/8/15.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EasyCenterManager.h"
#import "EasyService.h"
#import "EasyCharacteristic.h"
#import "EasyPeripheral.h"
#import "EasyDescriptor.h"


/**
 * 模糊搜索设备规则
 * 用户可以自定义，更具peripheral里面的名称，广播数据，RSSI来赛选需要的连接的设备
 */
typedef BOOL (^blueToothScanRule)(EasyPeripheral *peripheral);

/**
 * 搜索到设备回调
 * peripheral 已经连接上的设备
 * error是扫描错误信息
 */
typedef void (^blueToothScanCallback)(EasyPeripheral *peripheral , NSError *error );


/**
 * 搜索到设备回调
 * peripheralDict 里面是所有符合规则的设备。key:peripheral value:error(如果error里面有值，说面连接出现错误，需要处理)
 * error是扫描错误信息
 */
typedef void (^blueToothScanAllCallback)(NSArray<EasyPeripheral *> *deviceArray , NSError *error );


@interface EasyBlueToothManager : NSObject


/**
 * 单例
 */
+ (instancetype)shareInstance ;

#pragma mark - 扫描设备

- (void)startScanDevice ;

- (void)stopScanDevice ;

- (void)connectDeviceWithName:(NSString *)name
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanCallback)callback ;


- (void)connectDeviceWithRule:(blueToothScanRule)rule
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanCallback)callback ;

- (void)connectAllDeviceWithName:(NSString *)name
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanAllCallback)callback ;

- (void)connectAllDeviceWithRule:(blueToothScanRule)rule
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanAllCallback)callback ;
/**
 * timeInterval 搜索设备所用的时间
 * searchDeviceCallBack 每搜索到一个设备 就会 回调这个block
 */
- (void)searchDeviceWithTimeInterval:(NSTimeInterval)timeInterval
                            callback:(blueToothSearchDeviceCallback)searchDeviceCallBack ;

/**
 * deviceName 需要搜索设备的名称
 * timeInterval 搜索设备所用的时间
 * searchDeviceCallBack 每搜索到一个设备 就会 回调这个block
 */
- (void)searchDeviceWithName:(NSString *)deviceName
                timeInterval:(NSTimeInterval)timeInterval
                    callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack ;

/**
 * blurryName 需要搜索设备的名称 -----> 此方法和上面方法不同之处是 启用了模糊搜索。（模糊搜索规则请到方法内部查看）
 * timeInterval 搜索设备所用的时间
 * searchDeviceCallBack 每搜索到一个设备 就会 回调这个block
 */
- (void)searchDeviceWithBlurryName:(NSString *)blurryName
                      timeInterval:(NSTimeInterval)timeInterval
                          callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack ;


#pragma mark - 连接设备

/**
 * peripheral 连接一个设备（这个设备可以来自上面上面搜索到的设别）
 * collectDeviceCallback 设别连接状态的回调。（连接失败，断开连接，都会在这个block中回调）
// */
//- (void)connectDeviceWihtPeripheral:(EasyPeripheral *)peripheral
//                           callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback;
//
///**
// * peripheral 连接一个设备（这个设备可以来自上面上面搜索到的设别）
// * options  连接设备时需要过滤的一些参数
// * collectDeviceCallback 设别连接状态的回调。（连接失败，断开连接，都会在这个block中回调）
// */
//- (void)connectDeviceWihtPeripheral:(EasyPeripheral *)peripheral
//                            options:(NSDictionary *)options
//                           callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback;
//
///**
// * identifier 连接设备的唯一标识（如果是有绑定设备一说，可以在搜索到设别后把它保存到本地，然后需要连接的时候取出它来直接连接）
// * collectDeviceCallback 设别连接状态的回调。（连接失败，断开连接，都会在这个block中回调）
// */
//- (void)connectDeviceWihtIdentifier:(NSUUID *)identifier
//                           callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback;
//
///**
// * identifier 连接设备的唯一标识（如果是有绑定设备需求，可以在搜索到设别后把它保存到本地，然后需要连接的时候取出它来直接连接）
// * options  连接设备时需要过滤的一些参数
// * collectDeviceCallback 设别连接状态的回调。（连接失败，断开连接，都会在这个block中回调）
// */
//- (void)connectDeviceWihtIdentifier:(NSUUID *)identifier
//                            options:(NSDictionary *)options
//                           callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback;
//

#pragma mark - 读写操作

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * uuid 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */
//- (void)writeDataWithPeripheral:(EasyPeripheral *)peripheral
//                           data:(NSData *)data
//                      writeUUID:(NSString *)uuid
//                       callback:(blueToothOperationCallBack)writeCallback ;
//
///**
// * peripheral 写数据的设备
// * uuid 需要读取数据的特征
// * writeCallback 读取数据后的回调
// */
//- (void)readValueWithPeripheral:(EasyPeripheral *)peripheral
//                        readUUID:(NSString *)uuid
//                       callback:(blueToothOperationCallBack)writeCallback ;
//
///**
// * 建议此方法放在读写操作的前面
// */
//
///**
// * peripheral 写数据的设备
// * uuid 需要监听的特征值
// * writeCallback 读取数据后的回调
// */
//- (void)notifyDataWithPeripheral:(EasyPeripheral *)peripheral
//                      notifyUUID:(NSString *)uuid
//                    withCallback:(blueToothOperationCallBack )callback ;
//
///**
// * peripheral 写数据的设备
// * data  需要写入的数据
// * descroptor 需要往描述下写入数据
// * writeCallback 读取数据后的回调
// */
//- (void)writeDescroptorWithPeripheral:(EasyPeripheral *)peripheral
//                                 data:(NSData *)data
//                           descroptor:(EasyDescriptor *)descroptor
//                             callback:(blueToothOperationCallBack)writeCallback ;
//
///**
// * peripheral 需要读取描述的设备
// * descroptor 需要往描述下写入数据
// * writeCallback 读取数据后的回调
// */
//- (void)readDescroptorWithPeripheral:(EasyPeripheral *)peripheral
//                          descroptor:(EasyDescriptor *)descroptor
//                            callback:(blueToothOperationCallBack)writeCallback ;

#pragma mark - 断开操作

/*
 * peripheral 需要断开的设备
// */
//- (void)disconnectWithPeripheral:(EasyPeripheral *)peripheral ;
//
///*
// * identifier 需要断开的设备UUID
// */
//- (void)disconnectWithIdentifier:(NSUUID *)identifier ;
//
///*
// * 断开所有连接的设备
// */
//- (void)disconnectAllPeripheral ;


#pragma mark - 简便方法
/*
 *
 *
 *
 *
 *
 */
//- (void)connectWithDeviceName:(NSString *)deviceName
//                 scanInterval:(NSTimeInterval)timeInterval
//                  serviceUUID:(NSString *)serviceUUID
//                    writeUUID:(NSString *)writeUUID
//                   notifyUUID:(NSString *)notifyUUID
//                    writeData:(NSData *)data
//          stateChangeCallback:(blueToothStateChangeCallback *)stateChangeCallback
//         receivedDataCallback:(blueToothOperationCallBack *)receivedDataCallback ;
@end


















