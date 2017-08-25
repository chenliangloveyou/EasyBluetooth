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
 * 连接一个设备所经历的状态
 */
typedef NS_ENUM(NSUInteger , bluetoothState) {
    
    bluetoothStateReadly = 0,     //蓝牙准备就绪
    bluetoothStateScanDevice ,  //扫描设备
    bluetoothStateConnect ,     //连接设备
    bluetoothStateService ,     //获取服务
    bluetoothStateCharacter ,   //获取特征
    bluetoothStateWriteData ,   //写数据
    bluetoothStateReceivedData ,//获取通知数据
    bluetoothStateDestory ,     //断开设备
    
};

typedef NS_ENUM(NSUInteger , bluetoothErrorState) {
    
    bluetoothErrorStateNoReadly = 0 ,//系统蓝牙没有打开
    bluetoothErrorStateNoDevice ,    //没有找到设备
    bluetoothErrorStateConnectError ,//连接失败
    bluetoothErrorStateDisconnect ,  //设备失去连接
    bluetoothErrorStateNoService ,   //没有找到相应的服务
    bluetoothErrorStateNoCharcter,  //没有对应的特征
    bluetoothErrorStatewriteError,  //写数据失败
    bluetoothErrorStateNotifyError ,//监听通知失败
};


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
 * deviceArray 里面是所有符合规则的设备。(需要处理peripheral里面的error信息)
 * error是扫描错误信息
 */
typedef void (^blueToothScanAllCallback)(NSArray<EasyPeripheral *> *deviceArray , NSError *error );


@interface EasyBlueToothManager : NSObject


/**
 * 单例
 */
+ (instancetype)shareInstance ;


#pragma mark - 扫描并连接设备

- (void)connectDeviceWithName:(NSString *)name
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanCallback)callback ;

- (void)connectDeviceWithRule:(blueToothScanRule)rule
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanCallback)callback ;

- (void)connectDeviceWithIdentifier:(NSString *)identifier
                            timeout:(NSInteger)timeout
                           callback:(blueToothScanCallback)callback ;

- (void)connectDeviceWithName:(NSString *)name
                      timeout:(NSInteger)timeout
                  serviceUUID:(NSString *)serviceUUID
                   notifyUUID:(NSString *)notifyUUID
                    wirteUUID:(NSString *)writeUUID
                    writeData:(NSData *)data
                     callback:(blueToothScanCallback)callback;

- (void)connectAllDeviceWithName:(NSString *)name
                         timeout:(NSInteger)timeout
                        callback:(blueToothScanAllCallback)callback ;

- (void)connectAllDeviceWithRule:(blueToothScanRule)rule
                         timeout:(NSInteger)timeout
                        callback:(blueToothScanAllCallback)callback ;



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


















