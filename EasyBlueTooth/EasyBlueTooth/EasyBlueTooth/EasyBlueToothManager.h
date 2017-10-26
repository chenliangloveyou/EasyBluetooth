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
 * 一个蓝牙设备读写数据，所经历的全部的生命周期
 */
typedef NS_ENUM(NSUInteger , bluetoothState) {
    
//    bluetoothStateOpenTring = 0 ,//系统蓝牙正在打开
    bluetoothStateSystemReadly = 1,    //蓝牙准备就绪
    bluetoothStateDeviceFounded ,       //设备已被发现
    bluetoothStateDeviceConnected ,     //设备连接成功
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



#pragma mark - 单例
/**
 * 单例
 * alloc init 同样适用。（建议用单例形式）
 */
+ (instancetype)shareInstance ;


#pragma mark - 扫描设备

/**
 * 扫描单个设备 ---> 发现第一个设备符合name/rule的规则就会回调callback，停止扫描。
 * name：需要扫描设备的名称。
 * rule：给定的设备匹配规则。
 */
- (void)scanDeviceWithName:(NSString *)name
                  callback:(blueToothScanCallback)callback ;
- (void)scanDeviceWithRule:(blueToothScanRule)rule
                  callback:(blueToothScanCallback)callback ;

/**
 * 扫描所有设备  ---> 发现一个设备当符合给定name/rule的规则就回调block。
 * 最好给定一个扫描时间，不然会一直扫描。（在EasyManagerOptions.h中给定时间）
 *
 * name：需要扫描设备的名称。
 * rule：给定的设备匹配规则。
 */
- (void)scanAllDeviceWithName:(NSString *)name
                     callback:(blueToothScanAllCallback)callback ;
- (void)scanAllDeviceWithRule:(blueToothScanRule)rule
                     callback:(blueToothScanAllCallback)callback ;


#pragma mark - 连接设备

/**
 * 连接一个设备
 * identifier 设备唯一ID <上一步扫描成功后，可以把这个ID保存到本地。然后在下一次连接的时候，可以直接拿这个ID来连接，省略了扫描一步>
 * peripheral 一般来自上面搜索设备出来的设备。
 */
- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothScanCallback)callback ;
- (void)connectDeviceWithPeripheral:(EasyPeripheral *)peripheral
                           callback:(blueToothScanCallback)callback ;


#pragma mark - 扫描/连接 同时进行

/**
 * 扫描、连接同时进行，返回的是已经连接上的设备。一旦发现符合条件的设备就会停止搜索，然后直接连接，最后返回连接结果。
 * name       根据设备名称查找/连接设备。
 * rule       根据一定规则连接设备，依据peripheral里面的名称，广播数据，RSSI来赛选需要的连接的设备
 * identifier 连接一个确定ID的设备，一般此ID可以保存在本地。然后直接连接
 */
- (void)scanAndConnectDeviceWithName:(NSString *)name
                            callback:(blueToothScanCallback)callback ;
- (void)scanAndConnectDeviceWithRule:(blueToothScanRule)rule
                            callback:(blueToothScanCallback)callback ;
- (void)scanAndConnectDeviceWithIdentifier:(NSString *)identifier
                                  callback:(blueToothScanCallback)callback ;

/**
 * 连接已知名称的所有设备（返回的是一组此名称的设备全部连接成功）--->（慎用此功能）
 * name 设备名称
 * rule 规则
 */
- (void)scanAndConnectAllDeviceWithName:(NSString *)name
                               callback:(blueToothScanAllCallback)callback ;
- (void)scanAndConnectAllDeviceWithRule:(blueToothScanRule)rule
                               callback:(blueToothScanAllCallback)callback ;


#pragma mark - 读写操作

/**
 * 与设备的数据交互，读、写、监听。
 *
 * peripheral 写数据的设备，不管是不是已发现，已连接，未连接状态。内部会处理。
 * data  需要写入的数据
 * serviceUUID/writeUUID 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */
- (void)writeDataWithPeripheral:(EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                      writeUUID:(NSString *)writeUUID
                           data:(NSData *)data
                       callback:(blueToothOperationCallback)callback ;

- (void)readValueWithPeripheral:(EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                       readUUID:(NSString *)uuid
                       callback:(blueToothOperationCallback)callback ;
/**建议此方法放在读写操作的前面**/
- (void)notifyDataWithPeripheral:(EasyPeripheral *)peripheral
                     serviceUUID:(NSString *)serviceUUID
                      notifyUUID:(NSString *)notifyUUID
                     notifyValue:(BOOL)notifyValue
                    withCallback:(blueToothOperationCallback )callback ;

/**
 * 对描述进行操作。
 * peripheral 操作描述所在的设备
 * data  需要写入的数据
 * serviceUUID/characterUUID 所需要的UUID
 * writeCallback 读取数据后的回调
 */
- (void)writeDescriptorWithPeripheral:(EasyPeripheral *)peripheral
                          serviceUUID:(NSString *)serviceUUID
                        characterUUID:(NSString *)characterUUID
                                 data:(NSData *)data
                             callback:(blueToothOperationCallback)callback ;
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
 * 主动 开始/停止 扫描
 */
- (void)startScanDevice ;
- (void)stopScanDevice ;

/**
 * 断开以及连接上的设备操作
 * peripheral/identifier 代表设备
 */
- (void)disconnectWithPeripheral:(EasyPeripheral *)peripheral ;
- (void)disconnectWithIdentifier:(NSUUID *)identifier ;
- (void)disconnectAllPeripheral ;


#pragma mark - 简便方法
/**
 * 一行代码连接所有的设备
 * name         一直设别的名称
 * serviceuuid/notifyuuid/writeuuid   监听端口、写书的唯一ID
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


















