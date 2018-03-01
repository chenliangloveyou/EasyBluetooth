//
//  EasyBlueToothManager.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/15.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import "EasyBlueToothManager.h"

/**
 * 寻找特征的回调
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

#pragma mark - 扫描设备 （单个设别）

- (void)scanDeviceWithName:(NSString *)name
                  callback:(blueToothScanCallback)callback
{
    [self scanDeviceWithCondition:name
                         callback:callback];
}
- (void)scanDeviceWithRule:(blueToothScanRule)rule
                  callback:(blueToothScanCallback)callback
{
    [self scanDeviceWithCondition:rule
                         callback:callback];
}
- (void)scanDeviceWithCondition:(id)condition
                       callback:(blueToothScanCallback)callback
{
    NSAssert(condition, @"condition can't nil !");
    NSAssert(callback, @"callbck should handle!");
    
    if (!condition) {
        NSError *tempError = [NSError errorWithDomain:@"the condition is nil" code:bluetoothErrorStateNoDevice userInfo:nil];
        callback(nil,tempError);
        return ;
    }
    
    if (self.centerManager.manager.state == CBManagerStatePoweredOn) {
        self.bluetoothState = bluetoothStateSystemReadly ;
        if (self.bluetoothStateChanged) {
            self.bluetoothStateChanged(nil,bluetoothStateSystemReadly);
        }
    }
    else if(self.centerManager.manager.state == CBManagerStatePoweredOff){
        NSError *tempError = [NSError errorWithDomain:@"center manager state powered off and wraiting to turn on !" code:bluetoothErrorStateNoReadlyTring userInfo:nil];
        callback(nil,tempError);
    }
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, searchFlagType searchType) {
        
        NSLog(@"peripheral - %@  - %@ ,searchType - %zd",peripheral.name,peripheral.identifierString,searchType);
        if (searchType&searchFlagTypeFinish) {//扫描完成
            //说明在规定的时间没有扫描到设备
            //1，停止扫描
            [weakself.centerManager stopScanDevice];
            
            //2，通知外部调用者。  此时没找到设备有两种原因。1，系统蓝牙未开启。 2，周围没有设备。
            NSError *tempError = nil ;
            if (weakself.centerManager.manager.state == CBCentralManagerStatePoweredOff ) {
                tempError = [NSError errorWithDomain:@"center manager state powered off" code:bluetoothErrorStateNoReadly userInfo:nil];
            }
            else{
                tempError = [NSError errorWithDomain:@"device not found !" code:bluetoothErrorStateNoDevice userInfo:nil];
            }
            callback(nil , tempError);
            
            //3，不用往下了。下面是：发现了一个设备，判断是否是需要寻找的设备。
            return  ;
        }
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            
            //能进入if里面。说明返回的设备是查找的设备。如果不能就不予处理这个设备
            if ([(peripheral.name) isEqualToString:(name)] && searchType&searchFlagTypeAdded) {
                
                //1，停止扫描
                [weakself.centerManager stopScanDevice];
                
                //2，改变当前状态
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                //3，通知外部
                callback(peripheral,nil);
                
            }
        }
        else{
            
            blueToothScanRule rule = (blueToothScanRule)condition ;
            if (rule(peripheral) && searchType&searchFlagTypeAdded ) {//能进if里面。说明这个设备是符合要求的
                
                [weakself.centerManager stopScanDevice];
                
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                callback(peripheral,nil);
            }
        }
        
    }];
}

- (void)scanAllDeviceAsyncWithRule:(blueToothScanRule)rule
                          callback:(blueToothScanAsyncCallback)callback
{
    if (self.managerOptions.scanTimeOut == NSIntegerMax) {
        self.managerOptions.scanTimeOut = 20 ;//默认一个时间
        NSAssert(NO, @"you should set a scanTimeOut value on EasyManagerOptions class");
    }
    NSAssert(callback, @"callbck should handle!");
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, searchFlagType searchType) {
        
        if (searchType&searchFlagTypeFinish) { //扫描时间到
            //1，停止扫描
            [weakself.centerManager stopScanDevice];
            //2，收集错误信息
            NSError *tempError = nil ;
            if (weakself.centerManager.manager.state == CBCentralManagerStatePoweredOff ) {
                tempError = [NSError errorWithDomain:@"center manager state powered off" code:bluetoothErrorStateNoReadly userInfo:nil];
            }
            //3，通知外部
            callback(nil , searchFlagTypeFinish ,tempError);
            return ;
        }
        
        if (rule(peripheral) ) {
            
            if (searchType&searchFlagTypeAdded) {
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
            }
            callback(peripheral , searchType ,nil);
        }
        
    }];
}

#pragma mark 扫描所有符合条件的设备
- (void)scanAllDeviceWithName:(NSString *)name callback:(blueToothScanAllCallback)callback
{
    [self scanAllDeviceWithCondition:name
                            callback:callback];
}
- (void)scanAllDeviceWithRule:(blueToothScanRule)rule callback:(blueToothScanAllCallback)callback
{
    [self scanAllDeviceWithCondition:rule
                            callback:callback];
}
- (void)scanAllDeviceWithCondition:(id)condition
                          callback:(blueToothScanAllCallback)callback
{
    if (self.managerOptions.scanTimeOut == NSIntegerMax) {
        self.managerOptions.scanTimeOut = 20 ;//默认一个时间
        NSAssert(NO, @"you should set a scanTimeOut value on EasyManagerOptions class");
    }
    NSAssert(condition, @"condition can't nil !");
    NSAssert(callback, @"callbck should handle!");
    
    kWeakSelf(self)
    __block NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, searchFlagType searchType) {
        
        if (searchType&searchFlagTypeFinish) { //扫描时间到
            
            //1，停止扫描
            [weakself.centerManager stopScanDevice];
            //2，收集错误信息
            NSError *tempError = nil ;
            if (weakself.centerManager.manager.state == CBCentralManagerStatePoweredOff ) {
                tempError = [NSError errorWithDomain:@"center manager state powered off" code:bluetoothErrorStateNoReadly userInfo:nil];
            }
            else{
                if (tempArray.count == 0) {
                    tempError = [NSError errorWithDomain:@"device not found !" code:bluetoothErrorStateNoDevice userInfo:nil];
                }
            }
            //3，通知外部
            callback(tempArray,tempError);
            return ;
        }
        
        if ([condition isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)condition ;
            if ([peripheral.name isEqualToString:name]) {
                BOOL isEixt = [EasyBlueToothManager isExitObject:peripheral inArray:tempArray];
                if (!isEixt) {
                    [tempArray addObject:peripheral];
                }
            }
        }
        else{
            blueToothScanRule rule = (blueToothScanRule) condition ;
            if (rule(peripheral)) {
                BOOL isEixt = [EasyBlueToothManager isExitObject:peripheral inArray:tempArray];
                if (!isEixt) {
                    [tempArray addObject:peripheral];
                }
            }
        }
    }];
}

+ (BOOL)isExitObject:(EasyPeripheral *)peripheral inArray:(NSMutableArray *)tempArray
{
    __block BOOL isExited = NO ;
    [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[EasyPeripheral class]]) {
            EasyPeripheral *tempP = (EasyPeripheral *)obj ;
            if ([tempP.identifier isEqual:peripheral.identifier]) {
                isExited = YES ;
                *stop = YES ;
            }
        }
        else{
            NSAssert(NO, @"tempArray have a undefine object !");
        }
    }];
    return isExited ;
    
}


#pragma mark - 连接设备

- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothConnectCallback)callback
{
    NSAssert(identifier, @"you can't connect a empty uuid");
    
    if (ISEMPTY(identifier)) {
        NSError *error = [NSError errorWithDomain:@"the identifier is empty !" code:bluetoothErrorStateIdentifierError userInfo:nil];
        callback(nil,error);
        return ;
    }
    kWeakSelf(self)
    NSUUID *UUID = [[NSUUID alloc]initWithUUIDString:identifier];
    NSString *UUIDString = UUID.UUIDString ;
    if (ISEMPTY(UUIDString)) {
        NSError *error = [NSError errorWithDomain:@"the identifier is not effect !" code:bluetoothErrorStateIdentifierError userInfo:nil];
        callback(nil,error);
        NSAssert(NO, @"you should check the identifier !") ;
        return ;
    }
    
    if ([self.centerManager.connectedDeviceDict objectForKey:UUIDString]) {
        
        //如果此设备已经连接成功，就直接返回
        EasyPeripheral *peripheral = weakself.centerManager.connectedDeviceDict[UUIDString];
        callback(peripheral ,nil );
    }
    else if ([self.centerManager.foundDeviceDict objectForKey:UUIDString]){
        
        //如果此设备已经被发现，
        EasyPeripheral *peripheral = weakself.centerManager.foundDeviceDict[UUIDString];
        [self connectDeviceWithPeripheral:peripheral
                                 callback:callback];
    }
    else{
        
        [weakself scanDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
            return [peripheral.identifierString isEqualToString:UUIDString];
        } callback:^(EasyPeripheral *peripheral, NSError *error) {
            
            if (error) {//寻找设备中发生错误，直接回调给外面。只要不是扫描时间到，还会继续扫描
                if (callback) {
                    callback(nil,error);//此时的 peripheral 一定是 nil
                }
            }
            else {
                
                if (!peripheral) return  ;
                
                weakself.bluetoothState = bluetoothStateDeviceFounded ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceFounded);
                }
                
                //找到设备后，调用连接设备
                [weakself connectDeviceWithPeripheral:peripheral
                                             callback:callback];
            }
        }] ;
    }
}

- (void)connectDeviceWithPeripheral:(EasyPeripheral *)peripheral
                           callback:(blueToothConnectCallback)callback
{
    if (!peripheral) {
        NSAssert(NO, @"the device is empty !");
        return ;
    }
    
    for (EasyPeripheral *tempP in [self.centerManager.connectedDeviceDict allValues]) {
        if ([tempP isEqual:peripheral]) {
            self.bluetoothState = bluetoothStateDeviceConnected ;
            if (self.bluetoothStateChanged) {
                self.bluetoothStateChanged(peripheral,bluetoothStateDeviceConnected);
            }
            callback(peripheral , nil );
            return ;
        }
    }
    
    kWeakSelf(self)
    [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut Options:self.managerOptions.connectOptions callback:^(EasyPeripheral *perpheral, NSError *error, deviceConnectType deviceConnectType) {
        
        switch (deviceConnectType) {
            case deviceConnectTypeDisConnect:
            {
                NSInteger errorCode = bluetoothErrorStateDisconnect ;
                if (weakself.managerOptions.autoConnectAfterDisconnect) {
                    //设备失去连接。正在重连...
                    [peripheral reconnectDevice];
                    errorCode = bluetoothErrorStateDisconnectTring ;
                }
                
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:errorCode userInfo:nil];
                }
                callback(peripheral,tempError);
            }break;
            case deviceConnectTypeSuccess :
            {
                weakself.bluetoothState = bluetoothStateDeviceConnected ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateDeviceConnected);
                }
                
                callback(peripheral , nil );
            }break ;
            case deviceConnectTypeFaild:
            case deviceConnectTypeFaildTimeout:
            {
                NSError *tempError = nil ;
                if (error) {
                    tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateConnectError userInfo:nil];
                }
                callback(peripheral,tempError);
            }break ;
            default:
                break;
        }
        
    }];
    
}

#pragma mark - 扫描设备 后 直接连接 设备 （上面两步操作同时完成）

- (void)scanAndConnectDeviceWithName:(NSString *)name
                            callback:(blueToothScanCallback)callback
{
    NSAssert(callback, @"you should handle the callback !");
    kWeakSelf(self)
    [self scanDeviceWithName:name callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            callback(peripheral,error);
            return ;
        }
        
        if (peripheral) {
            [weakself connectDeviceWithPeripheral:peripheral
                                         callback:callback];
        }
    }];
}

- (void)scanAndConnectDeviceWithRule:(blueToothScanRule)rule
                            callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self scanDeviceWithRule:rule callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        if (error) {
            callback(peripheral,error);
            return ;
        }
        
        if (peripheral) {
            [weakself connectDeviceWithPeripheral:peripheral callback:callback];
        }
    }];
}

- (void)scanAndConnectDeviceWithIdentifier:(NSString *)identifier
                                  callback:(blueToothScanCallback)callback
{
    [self connectDeviceWithIdentifier:identifier
                             callback:callback];
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
            
            callback(nil,error);
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
            
            callback(nil,error);
        }
    }];
}

- (void)dealScanedAllDeviceWithArray:(NSArray *)deviceArray error:(NSError *)error callback:(blueToothScanAllCallback)callback
{
    
    kWeakSelf(self)
    for (int i = 0; i < deviceArray.count; i++) {
        QueueStartAfterTime(0.3*i)
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
    kWeakSelf(self)
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:writeUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            callback(nil ,error );
            return  ;
        }
        
        NSAssert(character, @"attention : the characteristic is null ");
        [character writeValueWithData:data callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            
            NSError *tempError = nil ;
            if (error) {
                tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateWriteError userInfo:nil];
            }else{
                weakself.bluetoothState = bluetoothStateWriteDataSuccess ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateWriteDataSuccess);
                }
            }
            callback(data,tempError);
            
        }];
        
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
    kWeakSelf(self)
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:readUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            callback(nil ,error );
            return ;
        }
        
        NSAssert(character, @"attention : the characteristic is null ");
        [character readValueWithCallback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            
            NSError *tempError = nil ;
            if (error) {
                tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateReadError userInfo:nil];
            }
            else{
                weakself.bluetoothState = bluetoothStateReadSuccess ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateReadSuccess);
                }
            }
            callback(data,tempError);
            
        }];
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
    kWeakSelf(self)
    [self searchCharacteristicWithPeripheral:peripheral serviceUUID:serviceUUID operationUUID:notifyUUID callback:^(EasyCharacteristic *character, NSError *error) {
        
        if (error) {
            callback(nil ,error );
            return  ;
        }
        
        NSAssert(character, @"attention : the characteristic is null ");
        [character notifyWithValue:notifyValue callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            
            NSError *tempError = nil ;
            if (error) {
                tempError = [NSError errorWithDomain:error.domain code:bluetoothErrorStateNotifyError userInfo:nil];
            }
            else{
                weakself.bluetoothState = bluetoothStateNotifySuccess ;
                if (weakself.bluetoothStateChanged) {
                    weakself.bluetoothStateChanged(peripheral,bluetoothStateNotifySuccess);
                }
            }
            callback(data,tempError);
            
        }];
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
            callback(nil ,error );
            return ;
        }
        NSAssert(character, @"attention : the characteristic is null ");
        
        if (character.descriptorArray) {
            for (EasyDescriptor *tempD in character.descriptorArray) {
                [tempD writeValueWithData:data callback:^(EasyDescriptor *descriptor, NSError *error) {
                    
                    callback(descriptor.value,error);
                    
                }];
            }
        }
        else{
            
            NSError *tempError = [NSError errorWithDomain:@"the characteristic no have descripotor" code:bluetoothErrorStateNoDescriptor userInfo:nil];
            callback(nil,tempError);
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
            callback(nil ,error );
            return  ;
        }
        NSAssert(character, @"attention : the characteristic is null ");
        
        if (character.descriptorArray) {
            for (EasyDescriptor *tempD in character.descriptorArray) {
                [tempD readValueWithCallback:^(EasyDescriptor *descriptor, NSError *error) {
                    
                    callback(descriptor.value,error);
                }];
            }
        }
        else{
            
            NSError *tempError = [NSError errorWithDomain:@"the characteristic no have descripotor" code:bluetoothErrorStateNoDescriptor userInfo:nil];
            callback(nil,tempError);
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
            
            weakself.bluetoothState = bluetoothStateServiceFounded ;
            if (weakself.bluetoothStateChanged) {
                weakself.bluetoothStateChanged(peripheral,bluetoothStateServiceFounded);
            }
            
            
            [exitedService discoverCharacteristicWithCharacteristicUUIDs:@[operationuuid] callback:^(NSArray<EasyCharacteristic *> *characteristics, NSError *error) {
                
                EasyCharacteristic *exitedCharacter = nil ;
                for (EasyCharacteristic *tempCharacter in characteristics) {
                    if ([tempCharacter.UUID isEqual:operationuuid]) {
                        exitedCharacter = tempCharacter ;
                        break ;
                    }
                }
                
                NSAssert(exitedCharacter, @"you provide operationUUID is noxited ! please change UUID") ;
                
                if (exitedCharacter) {
                    
                    weakself.bluetoothState = bluetoothStateCharacterFounded ;
                    if (weakself.bluetoothStateChanged) {
                        weakself.bluetoothStateChanged(peripheral,bluetoothStateCharacterFounded);
                    }
                    
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

/**
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
                
                callback(data , error);
            }];
            
            if (!ISEMPTY(data)) {
                [weakself writeDataWithPeripheral:peripheral serviceUUID:serviceUUID writeUUID:writeUUID data:data callback:^(NSData *data, NSError *error) {
                    
                    callback(data , error);
                }] ;
            }
        }
        else{
            
            callback(nil , error);
        }
    }];
}
- (void)connectDeviceWithIdentifier:(NSString *)identifier
                        serviceUUID:(NSString *)serviceUUID
                         notifyUUID:(NSString *)notifyUUID
                          wirteUUID:(NSString *)writeUUID
                          writeData:(NSData *)data
                           callback:(blueToothOperationCallback)callback
{
    
}

#pragma mark - getter 

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


@end














