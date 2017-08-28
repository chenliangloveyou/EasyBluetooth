//
//  EasyBlueToothManager.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/15.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyBlueToothManager.h"

/**
 * 寻找 特征的回调
 */
typedef void (^blueToothFindCharacteristic)(EasyCharacteristic *character ,NSError *error);


@interface EasyBlueToothManager()

@property (nonatomic,strong)EasyCenterManager *centerManager ;

@end

@implementation EasyBlueToothManager

+ (instancetype)shareInstance
{
    static EasyBlueToothManager *share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[EasyBlueToothManager alloc]init];
    });
    return share;
}
- (EasyCenterManager *)centerManager
{
    if (nil == _centerManager) {
        
        _centerManager = [[EasyCenterManager alloc]initWithQueue:self.managerOptions.managerQueue options:self.managerOptions.managerDictionary];
        kWeakSelf(_centerManager)
        kWeakSelf(self)
        _centerManager.stateChangeCallback = ^(EasyCenterManager *manager, CBManagerState state) {
            if (state == CBManagerStatePoweredOn) {
                weakself.bluetoothState = bluetoothStateSystemReadly ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(nil,bluetoothStateSystemReadly);
                }
                
                [weak_centerManager startScanDevice];
            }
        };
    }
    return _centerManager ;
}
- (EasyManagerOptions *)managerOptions
{
    if (nil == _managerOptions) {
        _managerOptions = [[EasyManagerOptions alloc]init];
    }
    return _managerOptions ;
}


#pragma mark - 扫描设备

- (void)scanDeviceWithName:(NSString *)name
                  callback:(blueToothScanCallback)callback
{
    [self scanDeviceWithCondition:name callback:callback];
}
- (void)scanDeviceWithRule:(blueToothScanRule)rule
                  callback:(blueToothScanCallback)callback
{
    [self scanDeviceWithCondition:rule callback:callback];
}
- (void)scanDeviceWithCondition:(id)condition
                          callback:(blueToothScanCallback)callback
{
    NSAssert(condition, @"condition can't nil !");
    NSAssert(callback, @"callbck should handle");
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            if ([peripheral.name isEqualToString:name]) {
                [weakself.centerManager stopScanDevice];

                queueMainStart
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                
                callback(peripheral,nil);
                queueEnd
            }
        }
        else{
            blueToothScanRule rule = (blueToothScanRule) condition ;
            if (rule(peripheral)) {
                [weakself.centerManager stopScanDevice];
                queueMainStart
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                callback(peripheral,nil);
                queueEnd
            }
        }
        
        if (isfinish) {
            [weakself.centerManager stopScanDevice];
            
            queueMainStart
            if (weakself.centerManager.manager.state == CBCentralManagerStatePoweredOff ) {
                NSError *tempError = [NSError errorWithDomain:@"center manager state powered off" code:bluetoothErrorStateNoReadly userInfo:nil];
                callback(nil,tempError);
            }
            else{
                NSError *tempError = [NSError errorWithDomain:@"device not found !" code:bluetoothErrorStateNoDevice userInfo:nil];
                callback(nil , tempError );
            }
            queueEnd
        }
    }];
}

- (void)scanAllDeviceWithName:(NSString *)name callback:(blueToothScanAllCallback)callback
{
    [self scanAllDeviceWithCondition:name callback:callback];
}
- (void)scanAllDeviceWithRule:(blueToothScanRule)rule callback:(blueToothScanAllCallback)callback
{
    [self scanAllDeviceWithCondition:rule callback:callback];
}
- (void)scanAllDeviceWithCondition:(id)condition
                  callback:(blueToothScanAllCallback)callback
{
    if (self.managerOptions.scanTimeOut == NSIntegerMax) {
        NSAssert(NO, @"you should set a scanTimeOut value on EasyManagerOptions class");
    }
    NSAssert(condition, @"condition can't nil !");
    NSAssert(callback, @"callbck should handle");
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            if ([peripheral.name isEqualToString:name]) {
                [tempArray addObject:peripheral];
            }
        }
        else{
            blueToothScanRule rule = (blueToothScanRule) condition ;
            if (rule(peripheral)) {
                [tempArray addObject:peripheral];
            }
        }
        
        if (isfinish) {
            [weakself.centerManager stopScanDevice];
            
            queueMainStart
            if (weakself.centerManager.manager.state == CBCentralManagerStatePoweredOff ) {
                NSError *tempError = [NSError errorWithDomain:@"center manager state powered off" code:bluetoothErrorStateNoReadly userInfo:nil];
                callback(tempArray,tempError);
            }
            else{
                
                if (tempArray.count == 0) {
                    NSError *tempError = [NSError errorWithDomain:@"device not found !" code:bluetoothErrorStateNoDevice userInfo:nil];
                    callback(nil,tempError);
                }
                else{
                    callback(tempArray , nil );
                }
            }
            queueEnd
        }
    }];
}


#pragma mark - 连接设备


- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    if ([self.centerManager.connectedDeviceDict objectForKey:identifier]) {
     
        EasyPeripheral *peripheral = weakself.centerManager.connectedDeviceDict[identifier];
        
        [weakself connectDeviceWithPeripheral:peripheral callback:callback];
    }
    else{
        [weakself scanDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
            return [peripheral.identifier isEqual:identifier];
        } callback:^(EasyPeripheral *peripheral, NSError *error) {
           
            if (error) {
                if (callback) {//如果发现设备中出现错误，直接返回
                    callback(peripheral,error);
                }
            }
            else{
                
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                
                [weakself connectDeviceWithPeripheral:peripheral callback:callback];
            }
        }] ;
    }
}

- (void)connectDeviceWithPeripheral:(EasyPeripheral *)peripheral
                           callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut Options:self.managerOptions.connectOptions disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
        
        NSError *tempError = nil ;
        if (error) {
            tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateDisconnect userInfo:nil];
        }
        queueMainStart
        callback(peripheral,tempError);
        queueEnd
        
    } callback:^(EasyPeripheral *perpheral, NSError *error) {
        
        queueMainStart
        if (!error) {
            weakself.bluetoothState = bluetoothStateDeviceConnected ;
            if (weakself.bluetoothStateChanged) {
                weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceConnected);
            }
        }
        
        //error里面 - (1)连接超时 (2)系统方法连接失败
        NSError *tempError = nil ;
        if (error) {
            tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateConnectError userInfo:nil];
        }
        callback(peripheral,tempError);
        queueEnd
    }];
}

#pragma mark - 扫描设备 后 直接连接 设备 （上面两步操作同时完成）

- (void)scanAndConnectDeviceWithName:(NSString *)name
                            callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self scanDeviceWithName:name callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(peripheral,error);
            queueEnd
            return ;
        }
        
        [weakself connectDeviceWithPeripheral:peripheral callback:callback];
    }];
}

- (void)scanAndConnectDeviceWithRule:(blueToothScanRule)rule
                            callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self scanDeviceWithRule:rule callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(peripheral,error);
            queueEnd
            return ;
        }
        
        [weakself connectDeviceWithPeripheral:peripheral callback:callback];
    }];
}

- (void)scanAndConnectDeviceWithIdentifier:(NSString *)identifier
                                  callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self scanDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
        return [peripheral.identifier isEqual:identifier] ;
    } callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(peripheral,error);
            queueEnd
            return ;
        }
        
        [weakself connectDeviceWithPeripheral:peripheral callback:callback];
    }];
}


- (void)scanAndConnectAllDeviceWithName:(NSString *)name
                               callback:(blueToothScanAllCallback)callback
{
    kWeakSelf(self)
    [self scanAllDeviceWithName:name callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
        
        if (deviceArray.count > 0) {
            [weakself dealScanedAllDeviceWithArray:deviceArray error:error callback:callback] ;
        }
        else{
            queueMainStart
            callback(nil,error);
            queueEnd
        }
    }];
}

- (void)scanAndConnectAllDeviceWithRule:(blueToothScanRule)rule
                               callback:(blueToothScanAllCallback)callback
{
    kWeakSelf(self)
    [self scanAllDeviceWithRule:rule callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
      
        if (deviceArray.count > 0) {
            [weakself dealScanedAllDeviceWithArray:deviceArray error:error callback:callback] ;
        }
        else{
            queueMainStart
            callback(nil,error);
            queueEnd
        }
        
    }];
}

- (void)dealScanedAllDeviceWithArray:(NSArray *)deviceArray error:(NSError *)error callback:(blueToothScanAllCallback)callback
{
    
    kWeakSelf(self)
    for (int i = 0; i < deviceArray.count; i++) {
        QueueStartAfterTime(0.5*i)
        EasyPeripheral *tempPeripheral = deviceArray[i];
        [weakself connectDeviceWithPeripheral:tempPeripheral callback:^(EasyPeripheral *peripheral, NSError *error) {
            if (error) {
                peripheral.connectErrorDescription = error ;
            }
            if (i == deviceArray.count-1) {
                queueMainStart
                callback(deviceArray,nil);
                queueEnd
            }
        }];
        queueEnd
    }
    
}

#pragma mark - 读写操作

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * uuid 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */

- (void)writeDataWithPeripheral:(EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                      writeUUID:(NSString *)writeUUID
                           data:(NSData *)data
                       callback:(blueToothOperationCallback)callback
{
    
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:writeUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(nil ,error );
            queueEnd
        }
        else{
            NSAssert(character, @"attention : the characteristic is null ");
            [character writeValueWithData:data callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                
                queueMainStart
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateWriteError userInfo:nil];
                }
                callback(data,tempError);
                queueEnd
            }];
        }
       
    }];
   
}

/**
 * peripheral 写数据的设备
 * uuid 需要读取数据的特征
 * writeCallback 读取数据后的回调
 */
- (void)readValueWithPeripheral:(EasyPeripheral *)peripheral
                    serviceUUID:(NSString *)serviceUUID
                       readUUID:(NSString *)readUUID
                       callback:(blueToothOperationCallback)callback
{
    
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:readUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(nil ,error );
            queueEnd
        }
        else{
            NSAssert(character, @"attention : the characteristic is null ");
            [character readValueWithCallback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                queueMainStart
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateReadError userInfo:nil];
                }
                callback(data,tempError);
                queueEnd
            }];
        }
        
    }];
    
}

/**
 * peripheral 写数据的设备
 * uuid 需要监听的特征值
 * writeCallback 读取数据后的回调
 */
- (void)notifyDataWithPeripheral:(EasyPeripheral *)peripheral
                     serviceUUID:(NSString *)serviceUUID
                      notifyUUID:(NSString *)notifyUUID
                     notifyValue:(BOOL)notifyValue
                    withCallback:(blueToothOperationCallback)callback
{
    
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:notifyUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(nil ,error );
            queueEnd
        }
        else{
            NSAssert(character, @"attention : the characteristic is null ");
            [character notifyWithValue:notifyValue callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                queueMainStart
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateNotifyError userInfo:nil];
                }
                callback(data,tempError);
                queueEnd
            }];
        }
    }];
    
}


/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)writeDescriptorWithPeripheral:(EasyPeripheral *)peripheral
                          serviceUUID:(NSString *)serviceUUID
                        characterUUID:(NSString *)characterUUID
                                 data:(NSData *)data
                             callback:(blueToothOperationCallback)callback
{
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:characterUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(nil ,error );
            queueEnd
        }
        else{
            NSAssert(character, @"attention : the characteristic is null ");
           
            if (character.descriptorArray) {
                for (EasyDescriptor *tempD in character.descriptorArray) {
                    [tempD writeValueWithData:data callback:^(EasyDescriptor *descriptor, NSError *error) {
                        queueMainStart
                        callback(descriptor.value,error);
                        queueEnd
                    }];
                }
            }
            else{
                queueMainStart
                NSError *tempError = [NSError errorWithDomain:@"the characteristic no have descripotor" code:bluetoothErrorStateNoDescriptor userInfo:nil];
                callback(nil,tempError);
                queueEnd
            }
        }
    }];
    
}

/**
 * peripheral 需要读取描述的设备
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)readDescriptorWithPeripheral:(EasyPeripheral *)peripheral
                         serviceUUID:(NSString *)serviceUUID
                       characterUUID:(NSString *)characterUUID
                            callback:(blueToothOperationCallback)callback
{
    
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:characterUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            queueMainStart
            callback(nil ,error );
            queueEnd
        }
        else{
            NSAssert(character, @"attention : the characteristic is null ");
            
            if (character.descriptorArray) {
                for (EasyDescriptor *tempD in character.descriptorArray) {
                    [tempD readValueWithCallback:^(EasyDescriptor *descriptor, NSError *error) {
                        queueMainStart
                        callback(descriptor.value,error);
                        queueEnd
                    }];
                }
            }
            else{
                queueMainStart
                NSError *tempError = [NSError errorWithDomain:@"the characteristic no have descripotor" code:bluetoothErrorStateNoDescriptor userInfo:nil];
                callback(nil,tempError);
                queueEnd
            }
        }
    }];
    
}



- (void)searchCharacteristicWithPeripheral:(EasyPeripheral *)peripheral
                                               serviceUUID:(NSString *)serviceUUID
                                             operationUUID:(NSString *)operationUUID
                                                  callback:(blueToothFindCharacteristic)callback
{
    NSAssert([serviceUUID isKindOfClass:[NSString class]], @"you should change the uuid ti nsstring！");
    CBUUID *serviceuuid = [CBUUID UUIDWithString:serviceUUID];
    CBUUID *operationuuid =[CBUUID UUIDWithString:operationUUID];
    
    if (peripheral.state != CBPeripheralStateConnected) {
        
        NSError *error = [NSError errorWithDomain:@"the device does't connected ! please operation after connected !" code:bluetoothErrorStateNoConnect userInfo:nil] ;
        callback(nil,error);
    }
    
    kWeakSelf(self)
    [peripheral discoverDeviceServiceWithUUIDArray:@[serviceuuid] callback:^(EasyPeripheral *peripheral, NSArray<EasyService *> *serviceArray, NSError *error) {
        
        EasyService * exitedService = nil ;
        for (EasyService *tempService in serviceArray) {
            if ([tempService.UUID isEqual:serviceuuid]) {
                exitedService = tempService ;
                break ;
            }
        }
        
        NSAssert(exitedService, @"you provide serviceUUID is noxited ! please change the serviceuuid") ;
        
        if (exitedService) {
            queueMainStart
            weakself.bluetoothState = bluetoothStateServiceFounded ;
            if (weakself.bluetoothStateChanged) {
                weakself.bluetoothStateChanged(peripheral,bluetoothStateServiceFounded);
            }
            queueEnd
            
            [exitedService discoverCharacteristicWithCharacteristicUUIDs:@[operationuuid] callback:^(NSArray<EasyCharacteristic *> *characteristics, NSError *error) {
                
                EasyCharacteristic *exitedCharacter = nil ;
                for (EasyCharacteristic *tempCharacter in characteristics) {
                    if ([tempCharacter.UUID isEqual:operationuuid]) {
                        exitedCharacter = tempCharacter ;
                        break ;
                    }
                }
                
                NSAssert(exitedCharacter, @"you provide writeUUID is noxited ! please change the writeUUID") ;
                
                if (exitedCharacter) {
                    queueMainStart
                    weakself.bluetoothState = bluetoothStateCharacterFounded ;
                    if (weakself.bluetoothStateChanged) {
                        weakself.bluetoothStateChanged(peripheral,bluetoothStateCharacterFounded);
                    }
                    queueEnd
                    
                    callback(exitedCharacter ,error) ;
                }
                else{
                    NSError *error = [NSError errorWithDomain:@"you privode serviceuuid is not exited !" code:bluetoothErrorStateNoCharcter userInfo:nil] ;
                    callback(nil,error);
                }
                
            }];
            
        }
        else{
            NSError *error = [NSError errorWithDomain:@"you privode serviceuuid is not exited !" code:bluetoothErrorStateNoService userInfo:nil] ;
            callback(nil,error);
        }
        
    }];
}

#pragma mark - rssi

- (void)readRSSIWithPeripheral:(EasyPeripheral *)peripheral
                      callback:(blueToothReadRSSICallback)callback
{
    [peripheral readDeviceRSSIWithCallback:^(EasyPeripheral *peripheral, NSNumber *RSSI, NSError *error) {
        queueMainStart
        callback(peripheral,RSSI,error);
        queueEnd
    }];
}


#pragma mark - 扫描 断开操作


- (void)startScanDevice
{
    [self.centerManager startScanDevice];
}

- (void)stopScanDevice
{
    [self.centerManager stopScanDevice];
}

/*
 * peripheral 需要断开的设备
 */
- (void)disconnectWithPeripheral:(EasyPeripheral *)peripheral
{
    [peripheral disconnectDevice];
}

/*
 * identifier 需要断开的设备UUID
 */
- (void)disconnectWithIdentifier:(NSUUID *)identifier
{
    EasyPeripheral *tempPeripheral = self.centerManager.connectedDeviceDict[identifier];
    
    if (tempPeripheral) {
        [tempPeripheral disconnectDevice];
    }
}

/*
 * 断开所有连接的设备
 */
- (void)disconnectAllPeripheral
{
    [self.centerManager disConnectAllDevice];
}

#pragma mark - 简便方法

- (void)connectDeviceWithName:(NSString *)name
                  serviceUUID:(NSString *)serviceUUID
                   notifyUUID:(NSString *)notifyUUID
                    wirteUUID:(NSString *)writeUUID
                    writeData:(NSData *)data
                     callback:(blueToothOperationCallback)callback
{
    kWeakSelf(self)
    [self scanAndConnectDeviceWithName:name callback:^(EasyPeripheral *peripheral, NSError *error) {
       
        if (!error) {
            [weakself notifyDataWithPeripheral:peripheral serviceUUID:serviceUUID notifyUUID:notifyUUID notifyValue:YES withCallback:^(NSData *data, NSError *error) {
                
                queueMainStart
                callback(data , error);
                queueEnd
            }];
            
            if (!ISEMPTY(data)) {
                QueueStartAfterTime(0.5)
                [weakself writeDataWithPeripheral:peripheral serviceUUID:serviceUUID writeUUID:writeUUID data:data callback:^(NSData *data, NSError *error) {
                    queueMainStart
                    callback(data , error);
                    queueEnd
                }] ;
                queueEnd
            }
        }
        else{
            queueMainStart
            callback(nil , error);
            queueEnd
        }
    }];
}


@end














