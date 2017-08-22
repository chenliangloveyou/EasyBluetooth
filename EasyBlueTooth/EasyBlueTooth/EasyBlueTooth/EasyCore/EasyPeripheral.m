//
//  EasyPeripheral.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/14.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyPeripheral.h"

#import "EasyCenterManager.h"
#import "EasyService.h"
#import "EasyCharacteristic.h"
#import "EasyDescriptor.h"

@interface EasyPeripheral()<CBPeripheralDelegate>
{
        blueToothCollectDeviceCallback _blueToothCollectDeviceCallback ;
        NSDictionary *_connectOpertion ;
    
        //读取rssi回调结果
        blueToothReadRSSICallback _blueToothReadRSSICallback ;
    
        //设备发现服务回调
        blueToothFindServiceCallback _blueToothFindServiceCallback ;
    }

@end

@implementation EasyPeripheral

- (void)dealloc
{
        if (_stateChangedCallback) {
                [self.peripheral removeObserver:self forKeyPath:@"state"];
            }
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
        return self.peripheral.name ;
    }
- (BOOL)isConnected
{
        BOOL connect = NO ;
        if (self.peripheral.state == CBPeripheralStateConnected) {
                connect = YES ;
            }
        return connect ;
    }

- (void)connectDevice
{
        [self connectDeviceWithCallback:_blueToothCollectDeviceCallback];
    }

- (void)connectDeviceWithCallback:(blueToothCollectDeviceCallback)callback
{
        [self connectDeviceWithOptions:_connectOpertion
                                    callback:callback];
    }

- (void)connectDeviceWithOptions:(NSDictionary *)options
                        callback:(blueToothCollectDeviceCallback)callback
{
        if (callback) {
                _blueToothCollectDeviceCallback = [callback copy] ;
            }
    
        _connectOpertion = options ;
        [self.centerManager.manager connectPeripheral:self.peripheral options:options];
    }

- (void)setStateChangedCallback:(blueToothDeviceStateChangedCallback)stateChangedCallback
{
        NSAssert(stateChangedCallback, @"you should set a callback ！");
    
        _stateChangedCallback = [stateChangedCallback copy];
    
        [self.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    }

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
        CBPeripheral *periheral = (CBPeripheral *)object ;
    
        if (_stateChangedCallback) {
                _stateChangedCallback( self , periheral.state) ;
            }
        EasyLog(@"_stateChangedCallback = %ld",(long)periheral.state );
    
    }

/**
   * 断开连接
   */
- (void)disconnectDevice
{
        if (self.state == CBPeripheralStateConnected) {
                [self.centerManager.manager cancelPeripheralConnection:self.peripheral];
            }
    }


- (void)dealManagerConnectDeviceWithError:(NSError *)error
{
        if (_blueToothCollectDeviceCallback) {
                _blueToothCollectDeviceCallback(self, error);
            }
    }

- (void)dealManagerDisconnectDeviceWithError:(NSError *)error
{
    #warning  是否与上面的重复
        if (_stateChangedCallback ) {
                _stateChangedCallback(self, self.state);
            }
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
    
        [self.peripheral discoverServices:uuidArray];
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
        self.RSSI = peripheral.RSSI ;
        if (_blueToothReadRSSICallback) {
                _blueToothReadRSSICallback(self ,peripheral.RSSI ,error );
            }
    }
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
        self.RSSI = RSSI ;
        if (_blueToothReadRSSICallback) {
                _blueToothReadRSSICallback(self , RSSI ,error );
            }
    
    }

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
        for (CBService *tempService in peripheral.services) {
                EasyService *tempS  = [self searchServiceWithService:tempService] ;
                if (nil == tempS) {
                        EasyService *easyS = [[EasyService alloc]initWithService:tempService perpheral:self];
                        [self.serviceArray addObject:easyS];
                    }
            }
    
        if (_blueToothFindServiceCallback) {
                _blueToothFindServiceCallback(self , self.serviceArray , error );
            }
    
    }

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    #warning  待处理
    }

#pragma mark characteristic

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
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
                [peripheral readValueForCharacteristic:characteristic];
        
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


#pragma mark descriptor

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
                                if ([tempD.UUID isEqual:descriptor.UUID]) {
                                        [tempD dealOperationDescriptorWithType:OperationTypeRead error:error];
                                        EasyLog(@" %@ -- %@ == %@",tempD,tempD.UUID ,tempD.value);
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
                                if ([tempD.UUID isEqual:descriptor.UUID]) {
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
























