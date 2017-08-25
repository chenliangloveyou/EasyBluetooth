
# EasyBluetooth

一款iOS BLE蓝牙调试工具，非常简单容易，也可以作为一个蓝牙库，快速集成和开发。
可以两步搞定蓝牙开发操作。
第一步连接设别，第二部特征读写数据。

# Preview
![image](https://github.com/chenliangloveyou/EasyBluetooth/blob/master/EasyBlueTooth/EasyBlueTooth/preview/preview_1.gif)
![image](https://github.com/chenliangloveyou/EasyBluetooth/blob/master/EasyBlueTooth/EasyBlueTooth/preview/preview_2.gif)

![image](https://github.com/chenliangloveyou/EasyBluetooth/blob/master/EasyBlueTooth/EasyBlueTooth/preview/preview_3.png)
![image](https://github.com/chenliangloveyou/EasyBluetooth/blob/master/EasyBlueTooth/EasyBlueTooth/preview/preview_4.png)

# 使用方法

/**
 * 获取操作的单例
 */
+ (instancetype)shareInstance ;


#pragma mark - 扫描并连接设备

/**
 * 连接一个已知名字的设备
 * name 设备名称
 * timeout 扫描设备 连接设备所使用的最长时间。
 * callback 连接设备的回调信息
 */
- (void)connectDeviceWithName:(NSString *)name
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanCallback)callback ;

/**
 * 连接一个一定规则的设备，依据peripheral里面的名称，广播数据，RSSI来赛选需要的连接的设备
 * name 设备名称
 * timeout 扫描设备 连接设备所使用的最长时间。
 * callback 连接设备的回调信息
 */
- (void)connectDeviceWithRule:(blueToothScanRule)rule
                      timeout:(NSInteger)timeout
                     callback:(blueToothScanCallback)callback ;


/**
 * 连接一个确定ID的设备，一般此ID可以保存在本地。然后直接连接
 * name 设备名称
 * timeout 扫描设备 连接设备所使用的最长时间。
 * callback 连接设备的回调信息
 */
- (void)connectDeviceWithIdentifier:(NSString *)identifier
                            timeout:(NSInteger)timeout
                           callback:(blueToothScanCallback)callback ;

/**
 * 一行代码连接所有的设备
 * name         一直设别的名称
 * timeout      连接超时时间
 * serviceuuid  服务id
 * notifyuuid   监听端口的id
 * writeuuid    写数据的id
 * data         需要发送给设备的数据
 * callback     回调信息
 */
- (void)connectDeviceWithName:(NSString *)name
                      timeout:(NSInteger)timeout
                  serviceUUID:(NSString *)serviceUUID
                   notifyUUID:(NSString *)notifyUUID
                    wirteUUID:(NSString *)writeUUID
                    writeData:(NSData *)data
                     callback:(blueToothScanCallback)callback;

/**
 * 连接已知名称的所有设备（返回的是一组此名称的设备全部连接成功）
 * name 设备名称
 * timeout 扫描设备 连接设备所使用的最长时间。
 * callback 连接设备的回调信息
 */
- (void)connectAllDeviceWithName:(NSString *)name
                         timeout:(NSInteger)timeout
                        callback:(blueToothScanAllCallback)callback ;

/**
 * 连接已知规则的全部设备（返回的是一组此名称的设备全部连接成功）
 * name 设备名称
 * timeout 扫描设备 连接设备所使用的最长时间。
 * callback 连接设备的回调信息
 */
- (void)connectAllDeviceWithRule:(blueToothScanRule)rule
                         timeout:(NSInteger)timeout
                        callback:(blueToothScanAllCallback)callback ;

# 联系作者

email: chenliangloveyou@163.com
