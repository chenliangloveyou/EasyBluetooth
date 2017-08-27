//
//  EasyBlueToothManager.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/15.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyBlueToothManager.h"

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
                weakself.bluetoothState = bluetoothStateReadly ;
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
    NSAssert(!condition, @"condition can't nil !");
    NSAssert(!callback, @"callbck should handle");
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            if ([peripheral.name isEqualToString:name]) {
                [weakself.centerManager stopScanDevice];
                queueMainStart
                callback(peripheral,nil);
                queueEnd
            }
        }
        else{
            blueToothScanRule rule = (blueToothScanRule) condition ;
            if (rule(peripheral)) {
                [weakself.centerManager stopScanDevice];
                queueMainStart
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
                callback(nil , nil );
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
    NSAssert(!condition, @"condition can't nil !");
    NSAssert(!callback, @"callbck should handle");
    
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
                callback(tempArray , nil );
            }
            queueEnd
        }
    }];
}


#pragma mark - 连接设备


- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothScanCallback)callback
{
    if ([self.centerManager.connectedDeviceDict objectForKey:identifier]) {
        EasyPeripheral *peripheral = self.centerManager.connectedDeviceDict[identifier];
        
        [self connectDeviceWithPeripheral:peripheral callback:callback];
    }
    else{
        [self scanDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
            return [peripheral.identifier isEqual:identifier];
        } callback:^(EasyPeripheral *peripheral, NSError *error) {
            [self connectDeviceWithPeripheral:peripheral callback:callback];
        }] ;
    }
}

- (void)connectDeviceWithPeripheral:(EasyPeripheral *)peripheral
                           callback:(blueToothScanCallback)callback
{
    [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut Options:self.managerOptions.connectOptions disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
        queueMainStart
        NSError *tempError = nil ;
        if (error) {
            tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateDisconnect userInfo:nil];
        }
        callback(peripheral,tempError);
        queueEnd
    } callback:^(EasyPeripheral *perpheral, NSError *error) {
        
        queueMainStart
        NSError *tempError = nil ;
        if (error) {
            tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateDisconnect userInfo:nil];
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
        [weakself connectDeviceWithPeripheral:peripheral callback:callback];
    }];
}

- (void)scanAndConnectDeviceWithRule:(blueToothScanRule)rule
                            callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self scanDeviceWithRule:rule callback:^(EasyPeripheral *peripheral, NSError *error) {
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
        [weakself connectDeviceWithPeripheral:peripheral callback:callback];
    }];
}

- (void)scanAndConnectAllDeviceWithName:(NSString *)name
                               callback:(blueToothScanAllCallback)callback
{
    kWeakSelf(self)
    [self scanAllDeviceWithName:name callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
        [weakself dealScanedAllDeviceWithArray:deviceArray error:error callback:callback] ;
    }];
}

- (void)scanAndConnectAllDeviceWithRule:(blueToothScanRule)rule
                               callback:(blueToothScanAllCallback)callback
{
    kWeakSelf(self)
    [self scanAllDeviceWithRule:rule callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
        [weakself dealScanedAllDeviceWithArray:deviceArray error:error callback:callback] ;
    }];
}

- (void)dealScanedAllDeviceWithArray:(NSArray *)deviceArray error:(NSError *)error callback:(blueToothScanAllCallback)callback
{
#warning 此处应该考虑error的情况
    kWeakSelf(self)
    if (deviceArray.count) {
        for (int i = 0; i < deviceArray.count; i++) {
            QueueStartAfterTime(0.5*i)
            EasyPeripheral *tempPeripheral = deviceArray[i];
            [weakself connectDeviceWithPeripheral:tempPeripheral callback:^(EasyPeripheral *peripheral, NSError *error) {
                if (error) {
                    peripheral.connectErrorDescription = error ;
                }
                if (i == deviceArray.count-1) {
                    callback(deviceArray,nil);
                }
            }];
            queueEnd
        }
    }
    else{
        NSError *tempError = [NSError errorWithDomain:@"no found device" code:bluetoothErrorStateNoDevice userInfo:nil];
        callback(nil,tempError);
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
    
    EasyCharacteristic *characteristic = [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:writeUUID];
    
    if (characteristic) {
        [characteristic writeValueWithData:data callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            callback(data,error);
        }];
    }
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
    EasyCharacteristic *characteristic = [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:readUUID];
    
    if (characteristic) {
        [characteristic readValueWithCallback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            callback(data,error);
        }];
    }
    
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
    EasyCharacteristic *characteristic = [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:notifyUUID];
    
    if (characteristic) {
        [characteristic notifyWithValue:notifyValue callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            callback(data,error);
        }];
    }
    
}

- (EasyCharacteristic *)searchCharacteristicWithPeripheral:(EasyPeripheral *)peripheral
                                               serviceUUID:(NSString *)serviceUUID
                                             operationUUID:(NSString *)operationUUID
{
    CBUUID *serviceuuid = [CBUUID UUIDWithString:serviceUUID];
    CBUUID *operationuuid =[CBUUID UUIDWithString:operationUUID];
    
    __block EasyCharacteristic *searchCharacteristic = nil ;
    if (peripheral.state == CBPeripheralStateConnected) {
        
        [peripheral discoverDeviceServiceWithUUIDArray:@[serviceuuid] callback:^(EasyPeripheral *peripheral, NSArray<EasyService *> *serviceArray, NSError *error) {
            
            EasyService * exitedService = nil ;
            for (EasyService *tempService in serviceArray) {
                if ([tempService.UUID isEqual:serviceuuid]) {
                    exitedService = tempService ;
                    break ;
                }
            }
            
            NSAssert(exitedService, @"you provide serviceUUID is noxited ! please change the serviceuuid") ;
            
            [exitedService discoverCharacteristicWithCharacteristicUUIDs:@[operationuuid] callback:^(NSArray<EasyCharacteristic *> *characteristics, NSError *error) {
                
                EasyCharacteristic *exitedCharacter = nil ;
                for (EasyCharacteristic *tempCharacter in characteristics) {
                    if ([tempCharacter.UUID isEqual:operationuuid]) {
                        exitedCharacter = tempCharacter ;
                        break ;
                    }
                }
                
                NSAssert(exitedCharacter, @"you provide writeUUID is noxited ! please change the writeUUID") ;
                
                searchCharacteristic = exitedCharacter ;
                
            }];
            
        }];
        
    }
    else{
#warning 需要处理
    }
    return [searchCharacteristic copy] ;
}

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)writeDescroptorWithPeripheral:(EasyPeripheral *)peripheral
                          serviceUUID:(NSString *)serviceUUID
                            writeUUID:(NSString *)writeUUID
                                 data:(NSData *)data
                             callback:(blueToothOperationCallback)writeCallback
{
    EasyCharacteristic *tempCharacter = [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:nil];
}

/**
 * peripheral 需要读取描述的设备
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)readDescroptorWithPeripheral:(EasyPeripheral *)peripheral
                         serviceUUID:(NSString *)serviceUUID
                            readUUID:(NSString *)readUUID
                            callback:(blueToothOperationCallback)writeCallback
{

}

#pragma mark - rssi

- (void)readRSSIWithPeripheral:(EasyPeripheral *)peripheral
                      callback:(blueToothReadRSSICallback)callback
{
    [peripheral readDeviceRSSIWithCallback:^(EasyPeripheral *peripheral, NSNumber *RSSI, NSError *error) {
        callback(peripheral,RSSI,error);
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
       
        [weakself notifyDataWithPeripheral:peripheral serviceUUID:serviceUUID notifyUUID:notifyUUID notifyValue:YES withCallback:^(NSData *data, NSError *error) {
            callback(data , error);
        }];
        
        QueueStartAfterTime(0.5)
        [weakself writeDataWithPeripheral:peripheral serviceUUID:serviceUUID writeUUID:writeUUID data:data callback:^(NSData *data, NSError *error) {
            callback(data , error);
        }] ;
        queueEnd
    }];
}


@end














