//
//  BaseBlueTooth.h
//  EFHealth
//
//  Created by nf on 16/3/15.
//  Copyright © 2016年 ef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/**
 * 蓝牙类型定义
 */
typedef NS_ENUM(NSInteger, BlueToothType){
    
    BlueToothTypeBloodSugar = 1 ,
    BlueToothTypeBloodPressure = 2 ,
    BlueToothTypeTemperature = 3 ,
    BlueToothTypeOxygen = 4 ,
    BlueToothTypeUrine = 5 ,
    BlueToothTypeWeight = 6 ,
    BlueToothTypeSweat = 7 ,//汗液
};

/**
 * 蓝牙断开连接的原因
 */
typedef NS_ENUM(NSInteger , DisconnectType) {
    
    DisconnectTypeNotFind = 1 ,//未发现设备
    DisconnectTypeConnectFaild ,//没有连接成功
    DisconnectTypeConnectBreak ,//设备正常断开连接
    DisconnectTypeSeriousProblem,//连接过重中出现严重的问题，而通知控制器
    DisconnectTypeSystemNoOpen ,//系统没有打开蓝牙
};

/**
 * 蓝牙状态类型
 */
typedef NS_ENUM(NSInteger , StateType) {
    
    StateTypeFindDevice = 1 ,  //发现设备
    StateTypeFindService ,     //发现服务
    StateTypeFindcharacteristic ,//发现特征
    StateTypeSendOrderSuccess ,//发送命令成功
};


@class BaseBlueTooth ;

/**
 单纯的扫描设备回调
 devices 里面放着的是总共扫描到的设备
 error   错误信息
 */
typedef void(^BlueToothScanDevicesCallback)(BaseBlueTooth *blueTooth ,NSArray *devices , NSError *error);

/**
 蓝牙连接状态发生改变回调
 blueTooth 蓝牙本身类
 stateType 设备状态
 */
typedef void(^BlueToothStateChangedCallback)(BaseBlueTooth *blueTooth ,StateType stateType );

/**
 蓝牙失去连接回调
 blueTooth 蓝牙本身类
 disConnectType 失去连接的原因
 */
typedef void(^BlueToothDisConnectedCallback)(BaseBlueTooth *blueTooth,DisconnectType disConnectType);

/**
 蓝牙接受到数据回调
 blueTooth 蓝牙本身类
 receivedData 接受到的数据
 */
typedef void(^BlueToothDidReceivedDataCallback)(BaseBlueTooth *blueTooth,id receivedData);



@interface BaseBlueTooth : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic,strong)CBCentralManager *manager ;//中心管理者
@property (nonatomic,strong)CBPeripheral *peripheral ;//当前连接的设备

@property (nonatomic,strong)CBService        *service ;       //当前连接的服务
@property (nonatomic,strong)CBCharacteristic *writeCharacteristic ;//当前连接的特征
@property (nonatomic,strong)CBCharacteristic *notifyCharacteristic ;//当前连接的特征

@property (nonatomic,assign,readonly)NSInteger blueToothType ;//当前蓝牙类型
@property (nonatomic,strong)CBUUID * notifyUUID ; //监听端口的uuid




@property (nonatomic,strong)NSString *saveUUID ;//上次保存的uuid

@property (nonatomic,copy)BlueToothStateChangedCallback StateChangedCallback ;

@property (nonatomic,copy)BlueToothDisConnectedCallback DisconnectedCallback ;

@property (nonatomic,copy)BlueToothDidReceivedDataCallback receivedDataCallBack ;



- (instancetype)initWithBlueToothType:(BlueToothType)blueToothType;

//扫描设备
- (void)scanDevicescallBack:(BlueToothScanDevicesCallback)scanDevicesCallback disConnectedCallback:(BlueToothDisConnectedCallback)disonnectedCallback ;


//连接设别
- (void)connectDeviceWithUUID:(NSString *)UUID sendOrder:(NSData *)sendOrder ;

@end






















