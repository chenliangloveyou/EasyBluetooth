//
//  EasyCharacteristic.h
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

typedef NS_ENUM(NSUInteger ,OperationType) {
    OperationTypeWrite = 0 ,
    OperationTypeRead = 1 ,
    OperationTypeNotify ,
};

/**
 * 往特征上操作数据
 */
typedef void (^blueToothCharactersticOperateCallback)(EasyCharacteristic *characteristic ,NSData *data , NSError *error);

/**
 * 查找到特征上的描述回调
 */
typedef void (^blueToothFindDescriptorCallback)(NSArray<EasyDescriptor *> *descriptorArray , NSError *error);


@interface EasyCharacteristic : NSObject

/**
 * 特征名称
 */
@property (nonatomic,strong)NSString *name ;

/**
 * 特征的唯一标示
 */
@property (nonatomic,strong)CBUUID *UUID ;

/**
 * 系统提供的特此
 */
@property (nonatomic, weak) CBCharacteristic *characteristic;

/**
 * 特征所属的服务
 */
@property (nonatomic,weak ,readonly) EasyService *service ;

/**
 * 特征所属的设备
 */
@property (nonatomic,weak ,readonly) EasyPeripheral *peripheral ;

/**
 * 特征上所有的特性
 */
@property(nonatomic, assign,readonly) CBCharacteristicProperties properties;
@property (nonatomic,strong,readonly) NSString *propertiesString ;

/**
 * 所包含的数据
 */
@property(nonatomic,retain, readonly) NSData *value;

/**
 * 是否正在监听数据
 */
@property (nonatomic,assign,readonly)BOOL isNotifying ;

/**
 * 特征中所有的描述
 */
@property(nonatomic, strong) NSMutableArray<EasyDescriptor *> *descriptorArray ;

/**
 * 接收到的数据都在这个数组里面，记录最后5次的操作
 */
@property (nonatomic, strong, readonly) NSMutableArray *readDataArray ;
@property (nonatomic, strong, readonly) NSMutableArray *writeDataArray ;
@property (nonatomic, strong, readonly) NSMutableArray *notifyDataArray ;

/**
 * 初始化方法
 */
- (instancetype)initWithCharacteristic:(CBCharacteristic *)character ;
- (instancetype)initWithCharacteristic:(CBCharacteristic *)character perpheral:(EasyPeripheral *)peripheral ;

/**
 * 操作characteristic
 */
- (void)writeValueWithByte:(int8_t)byte callback:(blueToothCharactersticOperateCallback)callback ;
- (void)writeValueWithData:(NSData *)data callback:(blueToothCharactersticOperateCallback)callback ;
- (void)readValueWithCallback:(blueToothCharactersticOperateCallback)callback ;
- (void)notifyWithValue:(BOOL)value callback:(blueToothCharactersticOperateCallback)callback ;


/**
 * 处理 easyPeripheral操作完的回到
 */
- (void)dealOperationCharacterWithType:(OperationType)type error:(NSError *)error ;

/**
 * 查找特征中的描述
 */
- (EasyDescriptor *)searchDescriptoriWithDescriptor:(CBDescriptor *)descriptor ;


/**
 * 处理service中搜索到descriper的结果
 */
- (void)dealDiscoverDescriptorWithError:(NSError *)error ;

/**
 * 查找服务上的特征
 */
- (void)discoverDescriptorWithCallback:(blueToothFindDescriptorCallback)callback ;




@end























