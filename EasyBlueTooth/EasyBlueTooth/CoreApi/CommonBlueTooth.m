//
//  CommonBlueTooth.m
//  EFHealth
//
//  Created by nf on 16/3/6.
//  Copyright © 2016年 ef. All rights reserved.
//

#import "CommonBlueTooth.h"


@interface CommonBlueTooth()


@property (nonatomic,assign)sweatOrderType orderType  ;
@property (nonatomic,assign)NSUInteger sweatRate ;

@property (nonatomic,strong)NSMutableData *receiveData ;


@end

@implementation CommonBlueTooth

@synthesize manager = _manager ;
@synthesize peripheral = _peripheral ;


- (void)connectDeviceWithUUID:(NSString *)UUID orderType:(sweatOrderType)orderType sweatRate:(NSUInteger)sweatRate
{
    if (self.orderType==sweatOrderTypeSetupRate) {
        NSAssert((sweatRate>=1 && sweatRate<=300), @"the sweat rate mast between 1~300");
    }
    self.orderType =orderType ;
    self.sweatRate = sweatRate ;
    
    [super connectDeviceWithUUID:UUID sendOrder:nil];
}

- (void)writeDataToBlueTooth
{
    
    if (nil == self.writeCharacteristic || nil == self.peripheral) {
        [self.manager scanForPeripheralsWithServices:nil options:nil];
        return ;
    }
    [self.peripheral writeValue:nil
                  forCharacteristic:self.writeCharacteristic
                               type:CBCharacteristicWriteWithoutResponse];
    
}
//接受到蓝牙的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"接受数据失败：%@",error);
        return ;//362-40   440-38  352+ 374
    }
    NSLog(@"接收到数据： %@",characteristic.value);
    
    //如果不是这个服务来的数据，不用接受
    if (![characteristic.UUID isEqual:self.notifyUUID]) {
        NSLog(@"uuid= %@ 错误", characteristic.UUID) ;
        NSAssert(NO, @"uuid错误");
        return ;
    }
    
    //接受到的数据放到容器中
    [self.receiveData appendData:characteristic.value];
    
    if (self.receiveData.length > 100) {
        if (self.receivedDataCallBack) {
            self.receivedDataCallBack(self,self.receiveData);
        }
    }
   
    
}

- (NSMutableData *)receiveData
{
    if (nil == _receiveData) {
        _receiveData = [NSMutableData dataWithCapacity:100];
    }
    return _receiveData ;
}


@end


















