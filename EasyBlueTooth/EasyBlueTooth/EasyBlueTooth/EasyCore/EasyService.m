//
//  EasyService.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyService.h"

#import "EasyPeripheral.h"
#import "EasyCharacteristic.h"

#import "EasyUtils.h"

@interface EasyService()
{
    blueToothFindCharacteristicCallback _blueToothFindCharacteristicCallback ;
}
@property(nonatomic, strong) NSMutableArray<EasyCharacteristic *> *characteristicArray;

@end

@implementation EasyService



- (instancetype)initWithService:(CBService *)service
{
    if (self  = [self initWithService:service perpheral:_peripheral]) {
        
    }
    return self ;
}
- (instancetype)initWithService:(CBService *)service perpheral:(EasyPeripheral *)peripheral
{
    NSAssert(service, @"you should have a service to create easyservice !");
    if (self = [super init]) {
        _peripheral = peripheral ;
        _service = service ;
        _isOn = YES ;
        _isEnabled = YES;
    }
    return self ;
}

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@",self.service.UUID ];
}
- (CBUUID *)UUID
{
    return self.service.UUID ;
}
- (NSArray *)includedServices
{
    return self.service.includedServices ;
}


- (void)discoverCharacteristicWithCallback:(blueToothFindCharacteristicCallback)callback
{
    [self discoverCharacteristicWithCharacteristicUUIDs:nil
                                               callback:callback];
}

- (void)discoverCharacteristicWithCharacteristicUUIDs:(NSArray<CBUUID *> *)uuids
                                             callback:(blueToothFindCharacteristicCallback)callback
{
    NSAssert(callback, @"you should deal the callback");
    
    _blueToothFindCharacteristicCallback = [callback copy];
    
    [self.peripheral.peripheral discoverCharacteristics:uuids forService:self.service];
}

- (void)dealDiscoverCharacteristic:(NSArray *)characteristics error:(NSError *)error
{
    for (CBCharacteristic *tempCharacteristic in characteristics) {
        
        EasyCharacteristic *tempC  = [self searchCharacteristciWithCharacteristic:tempCharacteristic] ;
        if (nil == tempC) {
            EasyCharacteristic *character = [[EasyCharacteristic alloc]initWithCharacteristic:tempCharacteristic perpheral:self.peripheral];
            [self.characteristicArray addObject:character];
        }
    }
    
    if (_blueToothFindCharacteristicCallback) {
        _blueToothFindCharacteristicCallback(self.characteristicArray  , error );
        _blueToothFindCharacteristicCallback = nil ;
    }
}



- (EasyCharacteristic *)searchCharacteristciWithCharacteristic:(CBCharacteristic *)characteristic
{
    EasyCharacteristic *tempC = nil ;
    for (EasyCharacteristic *tCharacterstic in self.characteristicArray) {
        if ([characteristic.UUID isEqual:tCharacterstic.UUID]) {
            tempC = tCharacterstic ;
            break ;
        }
    }
    return tempC ;
    
}




- (NSMutableArray *)characteristicArray
{
    if (nil == _characteristicArray) {
        _characteristicArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _characteristicArray ;
    
}
@end






