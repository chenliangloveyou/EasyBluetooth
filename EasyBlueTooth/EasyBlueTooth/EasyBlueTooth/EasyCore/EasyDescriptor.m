//
//  EasyDescriptor.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/14.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyDescriptor.h"

#import "EasyPeripheral.h"
#import "EasyCharacteristic.h"

@interface EasyDescriptor()
{
    blueToothDescriptorOperateCallback _readCallback ;
    blueToothDescriptorOperateCallback _writeCallback ;
}
@end
@implementation EasyDescriptor

- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor peripheral:(EasyPeripheral *)peripheral
{
    if (self = [super init]) {
        _descroptor = descriptor ;
        _peripheral = peripheral ;
    }
    return self ;
}
- (CBUUID *)UUID
{
    return _descroptor.UUID ;
}
- (id)value
{
    return _descroptor.value ;
}
- (CBCharacteristic *)characteristic
{
    return _descroptor.characteristic ;
}


- (void)writeByte:(int8_t)byte callback:(blueToothDescriptorOperateCallback)callback
{
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [self writeValueWithData:data callback:callback];
}
- (void)writeValueWithData:(NSData *)data callback:(blueToothDescriptorOperateCallback)callback
{
    if (callback) {
        _writeCallback = [callback copy];
    }
    if (data) {
        [self.writeDataArray addObject:data];
        [self.peripheral.peripheral writeValue:data forDescriptor:self.descroptor];
    }
    else{
        NSAssert(NO, @"the data is null , fobit");
    }
}
- (void)readValueWithCallback:(blueToothDescriptorOperateCallback)callback
{
    if (callback) {
        _readCallback = [callback copy];
    }
    
    [self.peripheral.peripheral readValueForDescriptor:self.descroptor];
}


- (void)dealOperationDescriptorWithType:(OperationType)type error:(NSError *)error
{
    switch (type) {
        case OperationTypeRead:
            if (_readCallback) {
                _readCallback(self,error);
                _readCallback = nil ;
            }

            break;
        case OperationTypeWrite:
            if (_writeCallback) {
                _writeCallback(self,error);
                _writeCallback = nil ;
            }
        default:
            break;
    }
}


- (NSMutableArray *)readDataArray
{
    if ( nil == _readDataArray) {
        _readDataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _readDataArray ;
}
- (NSMutableArray *)writeDataArray
{
    if (nil == _writeDataArray) {
        _writeDataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _writeDataArray ;
}
@end


































