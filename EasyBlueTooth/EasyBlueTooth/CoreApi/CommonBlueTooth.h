//
//  CommonBlueTooth.h
//  EFHealth
//
//  Created by nf on 16/3/6.
//  Copyright © 2016年 ef. All rights reserved.
//

#import "BaseBlueTooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger , sweatOrderType) {
    
    sweatOrderTypeVersion = 0x01 ,//获取设备版本号
    sweatOrderTypeResume = 0x02 ,//恢复出厂设置
    sweatOrderTypeReadData = 0x03 , //读取温湿度数据
    sweatOrderTypeSetupRate = 0x04 ,//设置采集间隔时间
    sweatOrderTypeReadRate = 0x05 ,//读取设备中的采集频率
};


@interface CommonBlueTooth : BaseBlueTooth

@property (nonatomic,copy)void (^receiveHistoryFinish)(void) ;

@property (nonatomic,copy)void (^receivingDataFaild)(NSString *error);

- (void)connectDeviceWithUUID:(NSString *)UUID orderType:(sweatOrderType)orderType sweatRate:(NSUInteger)sweatRate;

@end






















