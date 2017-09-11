//
//  EasyService.h
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


/**
   * 发现服务上的特征回调
   */
typedef void (^blueToothFindCharacteristicCallback)(NSArray<EasyCharacteristic *> *characteristics , NSError *error );


@interface EasyService : NSObject


/**
   * 服务名称
   */
@property (nonatomic, strong,readonly) NSString *name;

/**
   * 系统提供出来的服务
   */
@property (nonatomic,strong)CBService *service ;
@property (nonatomic,strong)NSArray *includedServices ;

/**
   * 服务所在的设备
   */
@property (nonatomic,weak , readonly)EasyPeripheral *peripheral ;

/**
   * 服务的唯一标示
   */
@property (nonatomic,strong,readonly)CBUUID * UUID ;

/**
   * 服务是否是开启状态
   */
@property (nonatomic,assign)BOOL isOn ;

/**
   * 服务是否是可用状态
   */
@property (nonatomic,assign)BOOL isEnabled ;


/**
   * 服务中所有的特征
   */
@property(nonatomic, strong ,readonly) NSMutableArray<EasyCharacteristic *> *characteristicArray;


/**
   * 初始化方法
   */
- (instancetype)initWithService:(CBService *)service ;
- (instancetype)initWithService:(CBService *)service perpheral:(EasyPeripheral *)peripheral ;


/**
   * 查找服务中所有的特征
   */
- (EasyCharacteristic *)searchCharacteristciWithCharacteristic:(CBCharacteristic *)characteristic ;


/**
   * 查找服务上的特征
   */
- (void)discoverCharacteristicWithCallback:(blueToothFindCharacteristicCallback)callback ;

- (void)discoverCharacteristicWithCharacteristicUUIDs:(NSArray<CBUUID *> *)uuidArray
                                             callback:(blueToothFindCharacteristicCallback)callback ;

/**
   * 处理manager的连接结果
   */
- (void)dealDiscoverCharacteristic:(NSArray *)characteristics error:(NSError *)error;






@end











