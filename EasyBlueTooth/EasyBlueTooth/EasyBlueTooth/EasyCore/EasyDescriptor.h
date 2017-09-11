//
//  EasyDescriptor.h
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "EasyCharacteristic.h"

@class EasyDescriptor ;

typedef void (^blueToothDescriptorOperateCallback)(EasyDescriptor *descriptor , NSError *error);

@interface EasyDescriptor : NSObject

/**
 * 系统提供的描述
 */
@property (nonatomic,strong)CBDescriptor *descroptor ;

/**
 * 描述所述的特征
 */
@property(assign, readonly) CBCharacteristic *characteristic;

/**
 * 描述所属的设别
 */
@property (nonatomic,weak)EasyPeripheral *peripheral ;

/**
 * 描述的唯一标示
 */
@property (nonatomic,strong , readonly )CBUUID *UUID ;

/**
 * 当前描述上的值
 */
@property (nonatomic,strong , readonly) id value;

/**
 * 描述上读写操作的记录值
 */
@property (nonatomic,strong)NSMutableArray *readDataArray ;
@property (nonatomic,strong)NSMutableArray *writeDataArray ;

/**
 * 初始化方法
 */
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor ;
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor peripheral:(EasyPeripheral *)peripheral;

/**
 * 在描述上的读写操作
 */
- (void)writeByte:(int8_t)byte callback:(blueToothDescriptorOperateCallback)callback ;
- (void)writeValueWithData:(NSData *)data callback:(blueToothDescriptorOperateCallback)callback ;
- (void)readValueWithCallback:(blueToothDescriptorOperateCallback)callback ;


/**
 * 处理 easyPeripheral操作完的回到
 */
- (void)dealOperationDescriptorWithType:(OperationType)type error:(NSError *)error ;


@end














