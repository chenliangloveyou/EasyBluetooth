//
//  EasyBlueToothManager.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/15.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "EasyBlueToothManager.h"

@interface EasyBlueToothManager()<CBCentralManagerDelegate>

@property (nonatomic,strong)EasyCenterManager *centerManager ;
@end

@implementation EasyBlueToothManager

+ (instancetype)shareInstance
{
    
    static EasyBlueToothManager *share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[EasyBlueToothManager alloc]init];
        dispatch_queue_t queue = dispatch_queue_create("com.easyBluetootth.demo", 0);

        share->_centerManager = [[EasyCenterManager alloc]initWithQueue:queue];
    });
    return share;
}

- (void)startScanDevice
{
    [self.centerManager startScanDevice];
}

- (void)stopScanDevice
{
    [self.centerManager stopScanDevice];
}

- (void)searchDeviceWithTimeInterval:(NSTimeInterval)timeInterval callback:(blueToothSearchDeviceCallback)searchDeviceCallBack
{
    [self searchDeviceWithName:@"" timeInterval:timeInterval callBack:searchDeviceCallBack];
}
- (void)searchDeviceWithName:(NSString *)deviceName timeInterval:(NSTimeInterval)timeInterval callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack
{
    [self.centerManager scanDeviceWithTimeInterval:timeInterval callBack:^(EasyPeripheral *peripheral, BOOL isFinish) {
        searchDeviceCallBack(peripheral,  isFinish);
    }];
}
- (void)searchDeviceWithBlurryName:(NSString *)blurryName timeInterval:(NSTimeInterval)timeInterval callBack:(blueToothSearchDeviceCallback)searchDeviceCallBack
{
    
}



- (void)connectDeviceWihtIdentifier:(NSUUID *)identifier callback:(blueToothCollectDeviceCallback)collectDeviceCallback
{

}
- (void)connectDeviceWihtPeripheral:(EasyPeripheral *)peripheral
                            options:(NSDictionary *)options
                           callback:(blueToothCollectDeviceCallback)collectDeviceCallback
{


}

- (void)connectDeviceWihtPeripheral:(EasyPeripheral *)peripheral callback:(blueToothCollectDeviceCallback)collectDeviceCallback
{

}

- (void)connectDeviceWihtIdentifier:(NSUUID *)identifier options:(NSDictionary *)options callback:(blueToothCollectDeviceCallback)collectDeviceCallback
{

}


#pragma mark - 读写操作

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * uuid 数据需要写入到哪个特征下面
 * writeCallback 写入数据后的回调
 */
- (void)writeDataWithPeripheral:(EasyPeripheral *)peripheral
                           data:(NSData *)data
                      writeUUID:(NSString *)uuid
                       callback:(blueToothOperationCallBack)writeCallback
{

}

/**
 * peripheral 写数据的设备
 * uuid 需要读取数据的特征
 * writeCallback 读取数据后的回调
 */
- (void)readValueWithPeripheral:(EasyPeripheral *)peripheral
                       readUUID:(NSString *)uuid
                       callback:(blueToothOperationCallBack)writeCallback
{

}

/**
 * 建议此方法放在读写操作的前面
 */

/**
 * peripheral 写数据的设备
 * uuid 需要监听的特征值
 * writeCallback 读取数据后的回调
 */
- (void)notifyDataWithPeripheral:(EasyPeripheral *)peripheral
                      notifyUUID:(NSString *)uuid
                    withCallback:(blueToothOperationCallBack )callback
{

}

/**
 * peripheral 写数据的设备
 * data  需要写入的数据
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)writeDescroptorWithPeripheral:(EasyPeripheral *)peripheral
                                 data:(NSData *)data
                           descroptor:(EasyDescriptor *)descroptor
                             callback:(blueToothOperationCallBack)writeCallback
{

}

/**
 * peripheral 需要读取描述的设备
 * descroptor 需要往描述下写入数据
 * writeCallback 读取数据后的回调
 */
- (void)readDescroptorWithPeripheral:(EasyPeripheral *)peripheral
                          descroptor:(EasyDescriptor *)descroptor
                            callback:(blueToothOperationCallBack)writeCallback
{

}

#pragma mark - 断开操作

/*
 * peripheral 需要断开的设备
 */
- (void)disconnectWithPeripheral:(EasyPeripheral *)peripheral
{

}

/*
 * identifier 需要断开的设备UUID
 */
- (void)disconnectWithIdentifier:(NSUUID *)identifier
{

}

/*
 * 断开所有连接的设备
 */
- (void)disconnectAllPeripheral
{

}



- (void)connectWithDeviceName:(NSString *)deviceName
                 scanInterval:(NSTimeInterval)timeInterval
                  serviceUUID:(NSString *)serviceUUID
                    writeUUID:(NSString *)writeUUID
                   notifyUUID:(NSString *)notifyUUID writeData:(NSData *)data
          stateChangeCallback:(__autoreleasing blueToothStateChangeCallback *)stateChangeCallback
         receivedDataCallback:(__autoreleasing blueToothOperationCallBack *)receivedDataCallback
{
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{

}

@end














