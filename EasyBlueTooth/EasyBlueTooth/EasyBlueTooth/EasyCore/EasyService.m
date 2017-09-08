//
//  EasyService.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import "EasyService.h"

#import "EasyPeripheral.h"
#import "EasyCharacteristic.h"

#import "EasyUtils.h"

@interface EasyService()

@property(nonatomic, strong) NSMutableArray<EasyCharacteristic *> *characteristicArray;

@property(nonatomic,strong) NSMutableArray<blueToothFindCharacteristicCallback> *findCharacterCallbackArray ;

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

- (void)discoverCharacteristicWithCharacteristicUUIDs:(NSArray<CBUUID *> *)uuidArray
                                             callback:(blueToothFindCharacteristicCallback)callback
{
    NSAssert(callback, @"you should deal the callback");
    
    if (callback) {
        [self.findCharacterCallbackArray addObject:callback];
    }
    
    BOOL isAllUUIDExited = uuidArray.count > 0 ;//需要查找的UUID是否都存在
    for (CBUUID *tempUUID in uuidArray) {
        
        BOOL isExitedUUID = NO ;//数组里单个需要查找到UUID是否存在
        for (EasyCharacteristic *tempCharacter in self.characteristicArray) {
            if ([tempCharacter.UUID isEqual:tempUUID]) {
                isExitedUUID = YES ;
                break ;
            }
        }
        if (!isExitedUUID) {
            isAllUUIDExited = NO ;
            break ;
        }
    }
    
    if (isAllUUIDExited) {
        
        if (self.findCharacterCallbackArray.count > 0) {
            blueToothFindCharacteristicCallback callback = self.findCharacterCallbackArray.firstObject ;
            callback(self.characteristicArray,nil);
            callback = nil ;
            
            [self.findCharacterCallbackArray removeObjectAtIndex:0];
        }
       
    }
    else{
        
        EasyLog_S(@"寻找设备服务上的特征 %@  %@",self.peripheral.identifier.UUIDString,self.service.UUID);

        [self.peripheral.peripheral discoverCharacteristics:uuidArray forService:self.service];
    }
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
    
    if (self.findCharacterCallbackArray.count > 0) {
        blueToothFindCharacteristicCallback callback = self.findCharacterCallbackArray.firstObject ;
        callback(self.characteristicArray,nil);
        callback = nil ;
        
        [self.findCharacterCallbackArray removeObjectAtIndex:0];
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

- (NSMutableArray<blueToothFindCharacteristicCallback> *)findCharacterCallbackArray
{
    if (nil == _findCharacterCallbackArray) {
        _findCharacterCallbackArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _findCharacterCallbackArray ;
}

@end






