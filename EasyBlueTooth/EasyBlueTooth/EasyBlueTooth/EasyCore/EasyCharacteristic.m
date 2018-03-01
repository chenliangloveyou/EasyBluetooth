//
//  EasyCharacteristic.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import "EasyCharacteristic.h"

#import "EasyPeripheral.h"
#import "EasyDescriptor.h"
#import "EasyUtils.h"

#define kARRAYMAXCOUNT 5

@interface EasyCharacteristic()
{
    //查询完descripter后的回调
    blueToothFindDescriptorCallback _blueToothFindDescriptorCallback ;
    
    //操作特征所需的回调
    blueToothCharactersticOperateCallback _writeOperateCallback ;
    blueToothCharactersticOperateCallback _readOperateCallback ;
    blueToothCharactersticOperateCallback _notifyOperateCallback ;
    
}

@property (nonatomic, strong) NSMutableArray *readDataArray ;
@property (nonatomic, strong) NSMutableArray *writeDataArray ;
@property (nonatomic, strong) NSMutableArray *notifyDataArray ;

@property (nonatomic,strong)NSMutableArray<blueToothCharactersticOperateCallback> *readCallbackArray ;
@property (nonatomic,strong)NSMutableArray<blueToothCharactersticOperateCallback> *writeCallbackArray ;
@property (nonatomic,strong)NSMutableArray<blueToothCharactersticOperateCallback> *notifyCallbackArray ;

@end

@implementation EasyCharacteristic

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@",self.characteristic.UUID ];
}
- (CBUUID *)UUID
{
    return _characteristic.UUID;
}

- (CBCharacteristicProperties)properties
{
    return _characteristic.properties;
}
- (NSData *)value
{
    return _characteristic.value ;
}
- (BOOL)isNotifying
{
    return _characteristic.isNotifying ;
}


-(NSString *)propertiesString
{
    CBCharacteristicProperties temProperties = self.properties;
    
    NSMutableString *tempString = [NSMutableString string];
    
    if (temProperties & CBCharacteristicPropertyBroadcast) {
        [tempString appendFormat:@"Broadcast "];
    }
    if (temProperties & CBCharacteristicPropertyRead) {
        [tempString appendFormat:@"Read "];
    }
    if (temProperties & CBCharacteristicPropertyWriteWithoutResponse) {
        [tempString appendFormat:@"WriteWithoutResponse "];
    }
    if (temProperties & CBCharacteristicPropertyWrite) {
        [tempString appendFormat:@"Write "];
    }
    if (temProperties & CBCharacteristicPropertyNotify) {
        [tempString appendFormat:@"Notify "];
    }
    if (temProperties & CBCharacteristicPropertyIndicate)//notify
    {
        [tempString appendFormat:@"Indicate "];
    }
    if(temProperties & CBCharacteristicPropertyAuthenticatedSignedWrites)//indicate
    {
        [tempString appendFormat:@"AuthenticatedSignedWrites "];
    }
    if (tempString.length > 1) {
        [tempString replaceCharactersInRange:NSMakeRange(tempString.length-1, 1) withString:@""];
    }
    return tempString ;
}


- (instancetype)initWithCharacteristic:(CBCharacteristic *)character
{
    return [self initWithCharacteristic:character perpheral:_peripheral];
}
- (instancetype)initWithCharacteristic:(CBCharacteristic *)character perpheral:(EasyPeripheral *)peripheral
{
    if (self = [super init]) {
        _characteristic = character ;
        _peripheral = peripheral ;
    }
    return self ;
}

- (void)writeValueWithByte:(int8_t)byte callback:(blueToothCharactersticOperateCallback)callback
{
    NSAssert(byte, @"byte is null , you can't send a empty data to device");
    NSData *data = [[NSData alloc]initWithBytes:&byte length:1];
    [self writeValueWithData:data callback:callback];
}
- (void)writeValueWithData:(NSData *)data callback:(blueToothCharactersticOperateCallback)callback
{
    NSAssert(data, @"byte is null , you can't send a empty data to device");
    
    if (data) {
        [self addDataToArrayWithType:OperationTypeWrite data:data];
    }
    
    if (callback) {
        _writeOperateCallback = [callback copy];
    }
    
    CBCharacteristicWriteType writeType = callback ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse ;
    
    for (int i = 0; i < data.length; i+=20) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        dispatch_queue_t currentQueue = dispatch_get_current_queue() ;
#pragma clang diagnostic pop

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((i/20)*0.2 * NSEC_PER_SEC)), currentQueue, ^{

            NSUInteger subLength = data.length - i > 20 ? 20 : data.length-i ;
            NSData *subData = [data subdataWithRange:NSMakeRange(i, subLength)];
            
            EasyLog_S(@"往特征上写数据 %@ %@",self.characteristic.UUID,subData);
            [self.peripheral.peripheral writeValue:subData
                                 forCharacteristic:self.characteristic
                                              type:writeType];
        });
    }
}
//#warning ====需要一个写入队列
- (void)readValueWithCallback:(blueToothCharactersticOperateCallback)callback
{
    if (callback) {
        
        _readOperateCallback = [callback copy];
    }
    EasyLog_S(@"读取特征上的数据 %@",self.characteristic.UUID);
    [self.peripheral.peripheral readValueForCharacteristic:self.characteristic];
    
}

- (void)notifyWithValue:(BOOL)value callback:(blueToothCharactersticOperateCallback)callback
{
    if (callback) {
        _notifyOperateCallback = [callback copy];
    }
    
    if (self.peripheral) {
        
        EasyLog_S(@"监听特征上的通知 %@ %d",self.characteristic.UUID,value);
        [self.peripheral.peripheral setNotifyValue:value forCharacteristic:self.characteristic];
    }
    else{
        EasyLog(@"the peripheral is null !");
    }
}

- (void)dealOperationCharacterWithType:(OperationType)type error:(NSError *)error
{
    switch (type) {
        case OperationTypeRead:
            if (_readOperateCallback) {
                _readOperateCallback(self,self.value,error);
                _readOperateCallback = nil ;
            }
            
            if (self.characteristic.value) {
                [self addDataToArrayWithType:OperationTypeNotify data:self.value];
            }
            
            break;
        case OperationTypeWrite:
            if (_writeOperateCallback) {
                _writeOperateCallback(self,self.value,error);
                _writeOperateCallback = nil ;
            }
            break ;
        case OperationTypeNotify:
        {
            if (self.characteristic.value) {
                [self addDataToArrayWithType:OperationTypeNotify data:self.value];
            }
            if (_notifyOperateCallback) {
                _notifyOperateCallback(self,self.value,error);
            }
        }break ;
            
        default:
            break;
    }
}


- (EasyDescriptor *)searchDescriptoriWithDescriptor:(CBDescriptor *)descriptor
{
    EasyDescriptor *tempD = nil ;
    for (EasyDescriptor *tDescriptor in self.descriptorArray) {
        if ([descriptor.UUID isEqual:tDescriptor.UUID]) {
            tempD = tDescriptor ;
            break ;
        }
    }
    return tempD ;
}

- (void)discoverDescriptorWithCallback:(blueToothFindDescriptorCallback)callback
{
    if (self.characteristic) {
        
        if (callback) {
            _blueToothFindDescriptorCallback = [callback copy];
        }
        EasyLog_S(@"发现特征上的描述 %@",self.characteristic.UUID);
        [self.peripheral.peripheral discoverDescriptorsForCharacteristic:self.characteristic];
    }
    else{
        EasyLog(@" attention：you try find descroptor on a null characteristic ！");
    }
    
}

- (void)dealDiscoverDescriptorWithError:(NSError *)error
{
    for (CBDescriptor *tempD in self.characteristic.descriptors) {
        EasyDescriptor *tDescroptor = [self searchDescriptoriWithDescriptor:tempD];
        if (nil == tDescroptor) {
            EasyDescriptor *character = [[EasyDescriptor alloc]initWithDescriptor:tempD peripheral:self.peripheral];
            [self.descriptorArray addObject:character];
        }
    }
    
    if (_blueToothFindDescriptorCallback) {
        _blueToothFindDescriptorCallback(self.descriptorArray , error );
        _blueToothFindDescriptorCallback =nil ;
    }
}

- (void)addDataToArrayWithType:(OperationType)type data:(NSData *)data
{
    NSAssert(data, @"can't add an empty object to array");
    
    switch (type) {
        case OperationTypeWrite:
            if (self.writeDataArray.count >= kARRAYMAXCOUNT) {
                [self.writeDataArray removeLastObject];
            }
            [self.writeDataArray insertObject:data atIndex:0];
            break;
        case OperationTypeRead:
            if (self.readDataArray.count >= kARRAYMAXCOUNT) {
                [self.readDataArray removeLastObject];
            }
            [self.readDataArray insertObject:data atIndex:0];
            break;
        case OperationTypeNotify:
            if (self.notifyDataArray.count >= kARRAYMAXCOUNT) {
                [self.notifyDataArray removeLastObject];
            }
            [[self mutableArrayValueForKey:@"notifyDataArray"] insertObject:data atIndex:0];
//            [self.notifyDataArray insertObject:data atIndex:0];
            break;
        default:
            break;
    }
    
}


- (NSMutableArray *)readDataArray
{
    if ( nil == _readDataArray) {
        _readDataArray = [NSMutableArray arrayWithCapacity:kARRAYMAXCOUNT];
    }
    return _readDataArray ;
}
- (NSMutableArray *)writeDataArray
{
    if (nil == _writeDataArray) {
        _writeDataArray = [NSMutableArray arrayWithCapacity:kARRAYMAXCOUNT];
    }
    return _writeDataArray ;
}

- (NSMutableArray *)notifyDataArray
{
    if (nil == _notifyDataArray) {
        _notifyDataArray = [NSMutableArray arrayWithCapacity:kARRAYMAXCOUNT];
    }
    return _notifyDataArray ;
}


- (NSMutableArray<EasyDescriptor *> *)descriptorArray
{
    if (nil == _descriptorArray) {
        _descriptorArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _descriptorArray ;
}
@end














