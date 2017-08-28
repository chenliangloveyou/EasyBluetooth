//
//  EasyPeripheral.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyPeripheral.h"

#import "EasyCenterManager.h"
#import "EasyService.h"
#import "EasyCharacteristic.h"
#import "EasyDescriptor.h"

@interface EasyPeripheral()<CBPeripheralDelegate>
{
    NSUInteger _connectTimeOut ;//连接设备超时时间
    NSDictionary *_connectOpertion ;//需要连接设备所遵循的条件
    blueToothDisconnectCallback _disconnectCallback ;
    __block blueToothConnectDeviceCallback _connectCallback ;
    
    __block BOOL  _isReconnectDevice ;//用来处理发起连接时的参数问题。因为没调用连接一次，只能返回一次连接结果。
    
    //读取rssi回调结果
    blueToothReadRSSICallback _blueToothReadRSSICallback ;
    
    //设备发现服务回调
    blueToothFindServiceCallback _blueToothFindServiceCallback ;
}

//@property (nonatomic,copy)blueToothDeviceStateChangedCallback stateChangedCallback ;

@end

@implementation EasyPeripheral

- (void)dealloc
{
//    if (_stateChangedCallback) {
//        [self.peripheral removeObserver:self forKeyPath:@"state"];
//    }
    EasyLog(@"\n%@设备已销毁 %zd",self.name,self.deviceScanCount);
    _peripheral.delegate = nil ;
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
{
    if ([self initWithPeripheral:peripheral central:_centerManager]) {
        
    }
    return self ;
}
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(EasyCenterManager *)manager
{
    if (self = [super init]) {
        _centerManager = manager ;
        
        _peripheral = peripheral ;
        peripheral.delegate = self ;
        
        _connectTimeOut = 5 ;
        _isReconnectDevice = YES ;
        
    }
    return self ;
}
- (NSUUID *)identifier
{
    return self.peripheral.identifier ;
}
- (CBPeripheralState)state
{
    return self.peripheral.state ;
}

- (NSString *)name
{
    NSString* localName = [_advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    return localName ? localName : @"Unknown";
    
    return localName ;
}
- (NSNumber *)RSSI
{
    if (_RSSI.intValue == 127) {
        return nil ;
    }
    
    return _RSSI ;
}

- (BOOL)isConnected
{
    BOOL connect = NO ;
    if (self.peripheral.state == CBPeripheralStateConnected) {
        connect = YES ;
    }
    return connect ;
}

- (void)connectDeviceWithCallback:(blueToothConnectDeviceCallback)callback
{
    [self connectDeviceWithDisconnectCallback:nil
                                     Callback:callback];
}

- (void)connectDeviceWithDisconnectCallback:(blueToothDisconnectCallback)disconnectCallback
                                   Callback:(blueToothConnectDeviceCallback)callback
{
    [self connectDeviceWithTimeOut:_connectTimeOut
                disconnectCallback:disconnectCallback
                          callback:callback];
}

- (void)connectDeviceWithTimeOut:(NSUInteger)timeout
              disconnectCallback:(blueToothDisconnectCallback)disconnectCallback
                        callback:(blueToothConnectDeviceCallback)callback
{
    [self connectDeviceWithTimeOut:timeout
                           Options:nil
                disconnectCallback:disconnectCallback
                          callback:callback];
}

- (void)connectDeviceWithTimeOut:(NSUInteger)timeout
                         Options:(NSDictionary *)options
              disconnectCallback:(blueToothDisconnectCallback)disconnectCallback
                        callback:(blueToothConnectDeviceCallback)callback
{

    if (disconnectCallback) {
        _disconnectCallback = [disconnectCallback copy];
    }
    else{
        EasyLog(@"attention ! disconnectCallback is very importent , you should handle this callback");
    }
    
    NSAssert(callback, @"you should handle connect device callback !");
    
    _connectCallback = [callback copy];
    _connectTimeOut = timeout ;
    _connectOpertion = options ;

    _isReconnectDevice = YES ;

    [self.centerManager.manager connectPeripheral:self.peripheral options:options];
    
    //如果设定的时间内系统没有回调连接的结果。直接返回错误信息
    kWeakSelf(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_connectTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (!_isReconnectDevice) {
            return  ;
        }
        NSError *error =[NSError errorWithDomain:@"connect device timeout ~~" code:-101 userInfo:nil];
        if (_connectCallback) {
            _connectCallback(self,error);
        }
        _isReconnectDevice = NO ;
        
        [weakself disconnectDevice];
    });

}

- (void)reconnectDevice
{
    _isReconnectDevice = YES ;
    [self connectDeviceWithTimeOut:_connectTimeOut
                           Options:_connectOpertion
                disconnectCallback:_disconnectCallback
                          callback:_connectCallback];
}


- (void)dealDisconnectWithError:(NSError *)error
{
    if (_disconnectCallback) {
        _disconnectCallback(self ,error);
    }
}

- (void)dealDeviceConnectWithError:(NSError *)error
{
    if (_connectCallback) {
        _connectCallback(self, error);
    }
    _isReconnectDevice = NO ;
}


//- (void)setStateChangedCallback:(blueToothDeviceStateChangedCallback)stateChangedCallback
//{
//    NSAssert(stateChangedCallback, @"you should set a callback ！");
//    
//    _stateChangedCallback = [stateChangedCallback copy];
//    
//    [self.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//    
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CBPeripheral *periheral = (CBPeripheral *)object ;
    
//    if (_stateChangedCallback) {
//        _stateChangedCallback( self , periheral.state) ;
//    }
    EasyLog(@"_stateChangedCallback = %zd",periheral.state );
    
}


/**
 * 断开连接
 */
- (void)disconnectDevice
{
    if (self.state == CBPeripheralStateConnected) {
        [self.centerManager.manager cancelPeripheralConnection:self.peripheral];
    }
//    [self.centerManager.connectedDeviceDict removeObjectForKey:self.identifier];
}

- (void)resetDeviceScanCount
{
    self.deviceScanCount = -1 ;
}

- (void)discoverAllDeviceServiceWithCallback:(blueToothFindServiceCallback)callback
{
    
    [self discoverDeviceServiceWithUUIDArray:nil
                                    callback:callback];
}

- (void)discoverDeviceServiceWithUUIDArray:(NSArray<CBUUID *> *)uuidArray
                                  callback:(blueToothFindServiceCallback)callback
{
    NSAssert(callback, @"you should deal the callback");
    
    _blueToothFindServiceCallback = [callback copy];

    BOOL isAllUUIDExited = uuidArray.count > 0 ;//需要查找的UUID是否都存在
    
    for (CBUUID *tempUUID in uuidArray) {
        
        BOOL isExitedUUID = NO ;//数组里单个需要查找到UUID是否存在
        for (EasyService *tempSerevice in self.serviceArray) {
            if ([tempSerevice.UUID isEqual:tempUUID]) {
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
        if (_blueToothFindServiceCallback) {
            _blueToothFindServiceCallback(self , self.serviceArray , nil );
            _blueToothFindServiceCallback = nil ;
        }
    }
    else{
        
        EasyLog(@"discoverDeviceServiceWithUUIDArray");
        [self.peripheral discoverServices:uuidArray];
    }
}

- (EasyService *)searchServiceWithService:(CBService *)service
{
    EasyService *tempService = nil ;
    for (EasyService *tempS in self.serviceArray) {
        if ([tempS.UUID isEqual:service.UUID]) {
            tempService = tempS ;
            break ;
        }
    }
    return tempService ;
}


- (void)readDeviceRSSIWithCallback:(blueToothReadRSSICallback)callback
{
    NSAssert(callback, @"you should deal the callback");
    
    _blueToothReadRSSICallback = [callback copy];
    
    [self.peripheral readRSSI];
}


#pragma mark - CBPeripheralDelegate Methods

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    EasyLog(@"\n%@设备的rssi读取%@ %@",peripheral,peripheral.RSSI,error);

    self.RSSI = peripheral.RSSI ;
    if (_blueToothReadRSSICallback) {
        _blueToothReadRSSICallback(self ,peripheral.RSSI ,error );
    }
#pragma clang diagnostic pop
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    EasyLog(@"\n%@设备的rssi读取%@ %@",peripheral,RSSI,error);

    self.RSSI = RSSI ;
    if (_blueToothReadRSSICallback) {
        _blueToothReadRSSICallback(self , RSSI ,error );
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    EasyLog(@"\n%@设备发现服务%@ %@",peripheral,peripheral.services,error);

    for (CBService *tempService in peripheral.services) {
        EasyService *tempS  = [self searchServiceWithService:tempService] ;
        if (nil == tempS) {
            EasyService *easyS = [[EasyService alloc]initWithService:tempService perpheral:self];
            [self.serviceArray addObject:easyS];
        }
    }
    
    if (_blueToothFindServiceCallback) {
        _blueToothFindServiceCallback(self , self.serviceArray , error );
        _blueToothFindServiceCallback = nil ;
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    EasyLog(@"\n%@已连接上行的设备发现了服务%@ %@",peripheral,peripheral.services,error);

#warning  待处理
}

#pragma mark characteristic

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    EasyLog(@"\n%@上的发现了特征%@ %@",service,service.characteristics,error);

    EasyService *tempService = [self searchServiceWithService:service];
    
    if (tempService) {
        [tempService dealDiscoverCharacteristic:service.characteristics error:error];
    }
    else{
        NSAssert(NO, @"you should deal this error");
    }
    
}

#pragma mark - write read notify operition

//监听notify后
//或者写入数据后，数据会在这个接口里回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    EasyLog(@"\n%@上的发现了特征%@ %@",peripheral,characteristic,error);
    
    EasyService *tempService = [self searchServiceWithService:characteristic.service];
    EasyCharacteristic *character = [tempService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"attention ! this character is empty .");
    
    if (character.isNotifying) {
        [character dealOperationCharacterWithType:OperationTypeNotifyData error:error];
    }
    else{
        [character dealOperationCharacterWithType:OperationTypeRead error:error];
    }
}

//当特征注册通知后 会回调此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (characteristic.isNotifying) {
        //        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        //        [self disconnectDevice];
    }
    
    
    EasyService *easyService = [self searchServiceWithService:characteristic.service];
    EasyCharacteristic *character = [easyService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"attention ! this character is empty .");
    
    [character dealOperationCharacterWithType:OperationTypeNotify error:error];
    
    
}

// 当写入某个特征值后 外设代理执行的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    EasyService *tempService = [self searchServiceWithService:characteristic.service];
    EasyCharacteristic *character = [tempService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"attention ! this character is empty .");
    
    [character dealOperationCharacterWithType:OperationTypeWrite error:error];
    
}


#pragma mark - descriptor

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    EasyService *easyService = [self searchServiceWithService:characteristic.service];
    EasyCharacteristic *character = [easyService searchCharacteristciWithCharacteristic:characteristic];
    
    NSAssert(character, @"attention ! this character is empty .");
    
    [character dealDiscoverDescriptorWithError:error];
    
}

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //    NSLog(@"获取到Descriptors的值 uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
    
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    for (EasyService *tempS in self.serviceArray) {
        for (EasyCharacteristic *tempC in tempS.characteristicArray) {
            for (EasyDescriptor *tempD in tempC.descriptorArray) {
                if ([tempD.descroptor isEqual:descriptor]) {
                    [tempD dealOperationDescriptorWithType:OperationTypeRead error:error];
                    NSLog(@"%@== %@",tempD,tempD.UUID );
                    return;
                }
            }
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    EasyLog(@"didWriteValueForDescriptor\n%@ \n %@ \n %@",peripheral,descriptor,error);
    
    for (EasyService *tempS in self.serviceArray) {
        for (EasyCharacteristic *tempC in tempS.characteristicArray) {
            for (EasyDescriptor *tempD in tempC.descriptorArray) {
                if ([tempD.descroptor isEqual:descriptor]) {
                    [tempD dealOperationDescriptorWithType:OperationTypeWrite error:error];
                    return;
                }
            }
        }
    }
}


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    EasyLog(@"peripheralDidUpdateName");
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    EasyLog(@"didRetrievePeripherals%@\n%@\n",central,peripherals);
    
    int i = 0;
    for(CBPeripheral *peripheral in peripherals) {
        NSLog(@"%@",[NSString stringWithFormat:@"[%d] - peripheral : %@ with UUID : %@",i,peripheral,peripheral.identifier]);
        i++;
        //Do something on each known peripheral.
    }
    
}
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    EasyLog(@"didRetrieveConnectedPeripherals:%@\n%@",peripherals,central);
    
    
    int i = 0;
    for(CBPeripheral *peripheral in peripherals) {
        i++;
        EasyLog(@"%@",[NSString stringWithFormat:@"[%d] - peripheral : %@ with UUID : %@",i,peripheral,peripheral.identifier]);
        //Do something on each connected peripheral.
    }
    
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    NSLog(@"peripheralDidInvalidateServices  %@",peripheral);
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"didModifyServices%@ \n%@",invalidatedServices,peripheral);
}





- (NSMutableArray *)serviceArray
{
    if (nil == _serviceArray) {
        _serviceArray = [NSMutableArray array];
    }
    return _serviceArray ;
    
}
@end
























