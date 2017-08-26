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
        _centerManager.stateChangeCallback = ^(EasyCenterManager *manager, CBManagerState state) {
            if (state == CBManagerStatePoweredOn) {
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

- (void)connectDeviceWithName:(NSString *)name timeout:(NSInteger)timeout serviceUUID:(NSString *)serviceUUID notifyUUID:(NSString *)notifyUUID wirteUUID:(NSString *)writeUUID writeData:(NSData *)data callback:(blueToothScanCallback)callback
{
    
}
- (void)connectDeviceWithName:(NSString *)name
                     callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut services:self.managerOptions.scanServiceArray  options:self.managerOptions.scanOptions callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
        EasyLog(@"%@",peripheral.name);
        if ([peripheral.name isEqualToString:name]) {
            
            [weakself.centerManager stopScanDevice];
            [peripheral resetDeviceScanCount];
            
            [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut Options:self.managerOptions.connectOptions disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
                queueMainStart
                callback(peripheral,error);
                queueEnd
            } callback:^(EasyPeripheral *perpheral, NSError *error) {
                
                queueMainStart
                callback(peripheral,error);
                queueEnd
            }];
        }
        
        if (isfinish) {
            NSError *tempError = [NSError errorWithDomain:@"search device timeout !" code:-1-1 userInfo:nil];
            queueMainStart
            callback(nil,tempError);
            queueEnd
        }
    }];
}
- (void)connectDeviceWithRule:(blueToothScanRule)rule
                     callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut
                                          services:self.managerOptions.scanServiceArray
                                           options:self.managerOptions.scanOptions
                                          callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
                                              
                                              if (rule(peripheral)) {
                                                  
                                                  [weakself.centerManager stopScanDevice];
                                                  [peripheral resetDeviceScanCount];
                                                  
                                                  [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut
                                                                               Options:self.managerOptions.scanOptions
                                                                    disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
                                                                        queueMainStart
                                                                        callback(peripheral,error);
                                                                        queueEnd
                                                                    } callback:^(EasyPeripheral *perpheral, NSError *error) {
                                                                        
                                                                        queueMainStart
                                                                        callback(peripheral,error);
                                                                        queueEnd
                                                                    }];
                                              }
                                              
                                              if (isfinish) {
                                                  NSError *tempError = [NSError errorWithDomain:@"search device timeout !" code:-1-1 userInfo:nil];
                                                  callback(nil,tempError);
                                              }
                                          }];
}
- (void)connectDeviceWithIdentifier:(NSString *)identifier
                           callback:(blueToothScanCallback)callback
{
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut
                                          services:self.managerOptions.scanServiceArray
                                           options:self.managerOptions.scanOptions
                                          callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
                                              EasyLog(@"%@",peripheral.name);
                                              if ([peripheral.identifier isEqual:identifier]) {
                                                  
                                                  [weakself.centerManager stopScanDevice];
                                                  [peripheral resetDeviceScanCount];
                                                  
                                                  [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut
                                                                               Options:self.managerOptions.scanOptions
                                                                    disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
                                                                        queueMainStart
                                                                        callback(peripheral,error);
                                                                        queueEnd
                                                                    } callback:^(EasyPeripheral *perpheral, NSError *error) {
                                                                        
                                                                        queueMainStart
                                                                        callback(peripheral,error);
                                                                        queueEnd
                                                                    }];
                                              }
                                              
                                              if (isfinish) {
                                                  NSError *tempError = [NSError errorWithDomain:@"search device timeout !" code:-1-1 userInfo:nil];
                                                  queueMainStart
                                                  callback(nil,tempError);
                                                  queueEnd
                                              }
                                          }];
}
- (void)connectAllDeviceWithName:(NSString *)name
                        callback:(blueToothScanAllCallback)callback
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut
                                          services:self.managerOptions.scanServiceArray
                                           options:self.managerOptions.scanOptions
                                          callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
                                              EasyLog(@"%@",peripheral.name);
                                              if ([peripheral.name isEqualToString:name]) {
                                                  
                                                  [tempArray addObject:peripheral];
                                                  
                                                  [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut
                                                                               Options:self.managerOptions.scanOptions
                                                                    disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
                                                                        if (error) {
                                                                            peripheral.connectErrorDescription = error ;
                                                                        }
                                                                        
                                                                    } callback:^(EasyPeripheral *perpheral, NSError *error) {
                                                                        if (error) {
                                                                            peripheral.connectErrorDescription = error ;
                                                                        }
                                                                    }];
                                              }
                                              
                                              if (isfinish) {
                                                  [weakself.centerManager stopScanDevice];
                                                  
                                                  NSError *tempError = [NSError errorWithDomain:@"search device timeout !" code:-101 userInfo:nil];
                                                  callback(tempArray,tempError);
                                              }
                                          }];
}
- (void)connectAllDeviceWithRule:(blueToothScanRule)rule
                        callback:(blueToothScanAllCallback)callback
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:self.managerOptions.scanTimeOut
                                          services:self.managerOptions.scanServiceArray
                                           options:self.managerOptions.scanOptions
                                          callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
                                              EasyLog(@"%@",peripheral.name);
                                              if (rule(peripheral)) {
                                                  
                                                  [tempArray addObject:peripheral];
                                                  
                                                  [peripheral connectDeviceWithTimeOut:self.managerOptions.connectTimeOut
                                                                               Options:self.managerOptions.scanOptions
                                                                    disconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
                                                                        if (error) {
                                                                            peripheral.connectErrorDescription = error ;
                                                                        }
                                                                    } callback:^(EasyPeripheral *perpheral, NSError *error) {
                                                                        if (error) {
                                                                            peripheral.connectErrorDescription = error ;
                                                                        }
                                                                    }];
                                              }
                                              
                                              if (isfinish) {
                                                  [weakself.centerManager stopScanDevice];
                                                  
                                                  NSError *tempError = [NSError errorWithDomain:@"search device timeout !" code:-101 userInfo:nil];
                                                  callback(tempArray,tempError);
                                              }
                                          }];
    
}
//
//- (void)startScanDevice
//{
//    [self.centerManager startScanDevice];
//}
//
//- (void)stopScanDevice
//{
//    [self.centerManager stopScanDevice];
//}
//
//- (void)searchDeviceWithTimeInterval:(NSTimeInterval)timeInterval callback:(blueToothSearchDeviceCallback)searchDeviceCallBack
//{
//    [self searchDeviceWithName:@"" timeInterval:timeInterval callBack:searchDeviceCallBack];
//}
//- (void)searchDeviceWithName:(NSString *)deviceName timeInterval:(NSTimeInterval)timeInterval callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack
//{
//    [self.centerManager scanDeviceWithTimeInterval:timeInterval callBack:^(EasyPeripheral *peripheral, BOOL isFinish) {
//        searchDeviceCallBack(peripheral,  isFinish);
//    }];
//}
//- (void)searchDeviceWithBlurryName:(NSString *)blurryName timeInterval:(NSTimeInterval)timeInterval callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack
//{
//    
//}
//


//- (void)connectDeviceWihtIdentifier:(NSUUID *)identifier callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback
//{
//
//}
//- (void)connectDeviceWihtPeripheral:(EasyPeripheral *)peripheral
//                            options:(NSDictionary *)options
//                           callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback
//{
//
//
//}
//
//- (void)connectDeviceWihtPeripheral:(EasyPeripheral *)peripheral callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback
//{
//
//}
//
//- (void)connectDeviceWihtIdentifier:(NSUUID *)identifier options:(NSDictionary *)options callback:(blueToothDeviceStateChangedCallback)collectDeviceCallback
//{
//
//}


#pragma mark - 读写操作

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * uuid 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */
//- (void)writeDataWithPeripheral:(EasyPeripheral *)peripheral
//                           data:(NSData *)data
//                      writeUUID:(NSString *)uuid
//                       callback:(blueToothOperationCallBack)writeCallback
//{
//
//}
//
///**
// * peripheral 写数据的设备
// * uuid 需要读取数据的特征
// * writeCallback 读取数据后的回调
// */
//- (void)readValueWithPeripheral:(EasyPeripheral *)peripheral
//                       readUUID:(NSString *)uuid
//                       callback:(blueToothOperationCallBack)writeCallback
//{
//
//}
//
///**
// * 建议此方法放在读写操作的前面
// */
//
///**
// * peripheral 写数据的设备
// * uuid 需要监听的特征值
// * writeCallback 读取数据后的回调
// */
//- (void)notifyDataWithPeripheral:(EasyPeripheral *)peripheral
//                      notifyUUID:(NSString *)uuid
//                    withCallback:(blueToothOperationCallBack )callback
//{
//
//}
//
///**
// * peripheral 写数据的设备
// * data  需要写入的数据
// * descroptor 需要往描述下写入数据
// * writeCallback 读取数据后的回调
// */
//- (void)writeDescroptorWithPeripheral:(EasyPeripheral *)peripheral
//                                 data:(NSData *)data
//                           descroptor:(EasyDescriptor *)descroptor
//                             callback:(blueToothOperationCallBack)writeCallback
//{
//
//}
//
///**
// * peripheral 需要读取描述的设备
// * descroptor 需要往描述下写入数据
// * writeCallback 读取数据后的回调
// */
//- (void)readDescroptorWithPeripheral:(EasyPeripheral *)peripheral
//                          descroptor:(EasyDescriptor *)descroptor
//                            callback:(blueToothOperationCallBack)writeCallback
//{
//
//}
//
//#pragma mark - 断开操作
//
///*
// * peripheral 需要断开的设备
// */
//- (void)disconnectWithPeripheral:(EasyPeripheral *)peripheral
//{
//
//}
//
///*
// * identifier 需要断开的设备UUID
// */
//- (void)disconnectWithIdentifier:(NSUUID *)identifier
//{
//
//}
//
///*
// * 断开所有连接的设备
// */
//- (void)disconnectAllPeripheral
//{
//
//}
//
//
//
//- (void)connectWithDeviceName:(NSString *)deviceName
//                 scanInterval:(NSTimeInterval)timeInterval
//                  serviceUUID:(NSString *)serviceUUID
//                    writeUUID:(NSString *)writeUUID
//                   notifyUUID:(NSString *)notifyUUID writeData:(NSData *)data
//          stateChangeCallback:(__autoreleasing blueToothStateChangeCallback *)stateChangeCallback
//         receivedDataCallback:(__autoreleasing blueToothOperationCallBack *)receivedDataCallback
//{
//    
//}
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//
//}

@end














