//
//  EasyBlueToothManager.h
//  EasyBlueTooth
//
//  Created by nf on 2016/8/15.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EasyCenterManager.h"
#import "EasyService.h"
#import "EasyCharacteristic.h"
#import "EasyPeripheral.h"
#import "EasyDescriptor.h"

#import "EasyManagerOptions.h"

/**
 * 一个设备所经历的状态
 */
typedef NS_ENUM(NSUInteger , bluetoothState) {
    
//    bluetoothStateOpenTring = 0 ,//系统蓝牙正在打开
    bluetoothStateSystemReadly = 1,    //蓝牙准备就绪
    bluetoothStateDeviceFounded ,       //扫描设备
    bluetoothStateDeviceConnected ,     //连接设备
    bluetoothStateServiceFounded ,     //获取服务
    bluetoothStateCharacterFounded ,   //获取特征
    bluetoothStateNotifySuccess ,       //监听通知成功
    bluetoothStateReadSuccess  ,       //读取数据成功
    bluetoothStateWriteDataSuccess ,   //写数据成功
    bluetoothStateDestory ,            //断开设备
    
};

/**
 * 错误的报错类型
 */
typedef NS_ENUM(NSUInteger , bluetoothErrorState) {
    
    bluetoothErrorStateNoReadlyTring = 0 ,//系统蓝牙没有打开。但是在扫描时间内，会等待蓝牙打开后继续扫描
    bluetoothErrorStateNoReadly = 1 ,//系统蓝牙没有打开。此时不会再自动扫描，只能重新扫描
    bluetoothErrorStateNoDevice ,    //没有找到设备
    bluetoothErrorStateConnectError ,//连接失败
    bluetoothErrorStateNoConnect,   //设别没有连接
    bluetoothErrorStateDisconnect ,  //设备失去连接
    bluetoothErrorStateDisconnectTring ,//设备失去连接 ,但是设置了自从重连，正在重连
    bluetoothErrorStateNoService ,   //没有找到相应的服务
    bluetoothErrorStateNoCharcter,  //没有对应的特征
    bluetoothErrorStateWriteError,  //写数据失败
    bluetoothErrorStateReadError ,  //读书节失败
    bluetoothErrorStateNotifyError ,//监听通知失败
    bluetoothErrorStateNoDescriptor,  //没有对应的特征

};


/**
 * 连接设备的时候蓝牙状态发生改变
 */
typedef void (^blueToothStateChanged)(EasyPeripheral *peripheral , bluetoothState state) ;

/**
 * 模糊搜索设备规则
 * 用户可以自定义，依据peripheral里面的名称，广播数据，RSSI来赛选需要的连接的设备
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

/**
 * 读/写/监听特征 操作回调
 */
typedef void (^blueToothOperationCallback)(NSData *data , NSError *error);



@interface EasyBlueToothManager : NSObject

/**
 * 这个参数里面全都是放置的初始条件
 */
@property (nonatomic,strong)EasyManagerOptions *managerOptions ;

/**
 * 蓝牙状态改变处理。<只需处理一种>
 * 方法一：外部可以KVO监听bluetoothState值的改变。
 * 方法二：bluetoothStateChanged 实现这个block回到
 */
@property (nonatomic,assign)bluetoothState bluetoothState ;
@property (nonatomic,strong,)__block blueToothStateChanged bluetoothStateChanged ;






/**
 * 单例
 * alloc init 同样可以用。（建议用单例形式）
 */
+ (instancetype)shareInstance ;


#pragma mark - 扫描设备

/**
 * 根据给定名称扫描单个设备
 */
- (void)scanDeviceWithName:(NSString *)name
                  callback:(blueToothScanCallback)callback ;

/**
 * 根据给定规则扫描单个设备
 */
- (void)scanDeviceWithRule:(blueToothScanRule)rule
                  callback:(blueToothScanCallback)callback ;

/**
 * 根据给定名称扫描符合名称的所有设备
 */
- (void)scanAllDeviceWithName:(NSString *)name
                     callback:(blueToothScanAllCallback)callback ;

/**
 * 根据规则扫描符合名称的所有设备
 */
- (void)scanAllDeviceWithRule:(blueToothScanRule)rule
                     callback:(blueToothScanAllCallback)callback ;


#pragma mark - 连接设备

/**
 * 根据设备的唯一ID 连接设备 <此种方法适合把设备的ID保存到本地的情况>
 */
- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothScanCallback)callback ;

/**
 * 根据给定的设备直接连接
 */
- (void)connectDeviceWithPeripheral:(EasyPeripheral *)peripheral
                           callback:(blueToothScanCallback)callback ;

#pragma mark - 扫描设备 后 直接连接 设备 （上面两步操作同时完成）

/**
 * 连接一个已知名字的设备
 * name 设备名称
 * callback 连接设备的回调信息
 */
- (void)scanAndConnectDeviceWithName:(NSString *)name
                            callback:(blueToothScanCallback)callback ;

/**
 * 连接一个一定规则的设备，依据peripheral里面的名称，广播数据，RSSI来赛选需要的连接的设备
 * name 设备名称
 * callback 连接设备的回调信息
 */
- (void)scanAndConnectDeviceWithRule:(blueToothScanRule)rule
                            callback:(blueToothScanCallback)callback ;

/**
 * 连接一个确定ID的设备，一般此ID可以保存在本地。然后直接连接
 * name 设备名称
 * callback 连接设备的回调信息
 */
- (void)scanAndConnectDeviceWithIdentifier:(NSString *)identifier
                                  callback:(blueToothScanCallback)callback ;

/**
 * 连接已知名称的所有设备（返回的是一组此名称的设备全部连接成功）
 * name 设备名称
 * callback 连接设备的回调信息
 */
- (void)scanAndConnectAllDeviceWithName:(NSString *)name
                               callback:(blueToothScanAllCallback)callback ;

/**
 * 连接已知规则的全部设备（返回的是一组此名称的设备全部连接成功）
 * name 设备名称
 * callback 连接设备的回调信息
 */
- (void)scanAndConnectAllDeviceWithRule:(blueToothScanRule)rule
                               callback:(blueToothScanAllCallback)callback ;


#pragma mark - 读写操作

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * uuid 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */
- (void)writeDataWithPeripheral:(EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                      writeUUID:(NSString *)writeUUID
                           data:(NSData *)data
                       callback:(blueToothOperationCallback)callback ;

/**
 * peripheral 写数据的设备
 * uuid 需要读取数据的特征
 * writeCallback 读取数据后的回调
 */
- (void)readValueWithPeripheral:(EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                       readUUID:(NSString *)uuid
                       callback:(blueToothOperationCallback)callback ;

/**
 * 建议此方法放在读写操作的前面
 */

/**
 * peripheral 写数据的设备
 * uuid 需要监听的特征值
 * writeCallback 读取数据后的回调
 */
- (void)notifyDataWithPeripheral:(EasyPeripheral *)peripheral
                     serviceUUID:(NSString *)serviceUUID
                      notifyUUID:(NSString *)notifyUUID
                     notifyValue:(BOOL)notifyValue
                    withCallback:(blueToothOperationCallback )callback ;

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)writeDescriptorWithPeripheral:(EasyPeripheral *)peripheral
                          serviceUUID:(NSString *)serviceUUID
                        characterUUID:(NSString *)characterUUID
                                 data:(NSData *)data
                             callback:(blueToothOperationCallback)callback ;

/**
 * peripheral 需要读取描述的设备
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)readDescriptorWithPeripheral:(EasyPeripheral *)peripheral
                         serviceUUID:(NSString *)serviceUUID
                       characterUUID:(NSString *)characterUUID
                            callback:(blueToothOperationCallback)callback ;


#pragma mark - rssi 

/**
 * 读取设备的rssi
 */
- (void)readRSSIWithPeripheral:(EasyPeripheral *)peripheral
                      callback:(blueToothReadRSSICallback)callback ;

#pragma mark - 扫描 断开操作

/**
 * 开始扫描
 */
- (void)startScanDevice ;
/**
 * 停止扫描
 */
- (void)stopScanDevice ;
/**
 * peripheral 需要断开的设备
  */
- (void)disconnectWithPeripheral:(EasyPeripheral *)peripheral ;

/**
 * identifier 需要断开的设备UUID
 */
- (void)disconnectWithIdentifier:(NSUUID *)identifier ;

/**
 * 断开所有连接的设备
 */
- (void)disconnectAllPeripheral ;


#pragma mark - 简便方法
/**
 * 一行代码连接所有的设备
 * name         一直设别的名称
 * serviceuuid  服务id
 * notifyuuid   监听端口的id
 * writeuuid    写数据的id
 * data         需要发送给设备的数据
 * callback     回调信息
 */
- (void)connectDeviceWithName:(NSString *)name
                  serviceUUID:(NSString *)serviceUUID
                   notifyUUID:(NSString *)notifyUUID
                    wirteUUID:(NSString *)writeUUID
                    writeData:(NSData *)data
                     callback:(blueToothOperationCallback)callback;
@end


















