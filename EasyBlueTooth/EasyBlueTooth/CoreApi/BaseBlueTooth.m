//
//  BaseBlueTooth.m
//  EFHealth
//
//  Created by nf on 16/3/15.
//  Copyright © 2016年 ef. All rights reserved.
//

#import "BaseBlueTooth.h"

@interface BaseBlueTooth()

@property (nonatomic,strong)CBUUID * serviceUUID ;//服务的uuid
@property (nonatomic,strong)CBUUID * writeUUID ;  //写特征的uuid
@property (nonatomic,strong)NSString *saveDefaultUUID ;//用于保存到本地的uuid

@property (nonatomic,strong)NSString *hardWareName ;//硬件设备名称

@property (nonatomic,strong)NSString *currentUUID ; //当前需要连接的设备
@property (nonatomic,strong)NSData *currentSendOrder ;//当前需要发送给外设的命令

@property (nonatomic,assign)NSInteger scanCount ;//扫描次数，如果扫描次数过多，说明有问题，通知控制器处理
@property (nonatomic,strong)NSMutableSet *scanedDevicesSet ;//当前扫描到设备的集合

@property (nonatomic,strong)BlueToothScanDevicesCallback scanDevicesCallback ;

@end

@implementation BaseBlueTooth

- (void)dealloc
{
    if (_manager) {
        [_manager stopScan];
        if (_peripheral) {
            NSLog(@" %@ break %@",_manager ,_peripheral);
            [_manager cancelPeripheralConnection:_peripheral];
        }
    }
    _peripheral = nil ;
    _manager = nil ;
    NSLog(@"\n the hardWare name %@ is dealloc !\n",self.hardWareName);
}
- (NSString *)saveUUID
{
    NSAssert(self.saveDefaultUUID.length, @"the default uuid is empty");
    return [[NSUserDefaults standardUserDefaults] objectForKey:self.saveDefaultUUID];
}
- (void)setSaveUUID:(NSString *)saveUUID
{
    [[NSUserDefaults standardUserDefaults] setObject:saveUUID forKey:self.saveDefaultUUID];
}
- (instancetype)initWithBlueToothType:(BlueToothType)blueToothType
{
    if (self = [super init]) {
        self.blueToothType = blueToothType ;
    }
    return self ;
}

- (void)scanDevicescallBack:(BlueToothScanDevicesCallback)scanDevicesCallback disConnectedCallback:(BlueToothDisConnectedCallback)disonnectedCallback
{
    self.scanDevicesCallback  = scanDevicesCallback ;
    self.DisconnectedCallback = disonnectedCallback ;
    
    if (self.peripheral) {
        [self.manager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil ;
    }
    [self scan];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        
        [weakSelf.manager stopScan];
        if (weakSelf.manager.state != CBCentralManagerStatePoweredOn) {
            return  ;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
        for (NSString *str in weakSelf.scanedDevicesSet) {
            [dict setObject:str forKey:str];
        }
        NSArray *devicesArr = [NSArray arrayWithArray:[dict allKeys]];
        scanDevicesCallback(weakSelf,devicesArr , nil );
    });
    
}
- (void)connectDeviceWithUUID:(NSString *)UUID sendOrder:(NSData *)sendOrder
{
    self.currentUUID = UUID ;
    self.currentSendOrder = sendOrder ;
    [self stopScan];
    
    if (self.peripheral.state == CBPeripheralStateConnected) {
        
        if (self.service) {
            
            if (self.writeCharacteristic) {
                [self writeDataToBlueTooth];
            }
            else{
                [self.peripheral discoverCharacteristics:nil forService:self.service];
            }
        }else{
            self.peripheral.delegate = self ;
            [self.peripheral discoverServices:nil];
        }
    }
    else{
        [self scan];
    }
}

- (void)scan
{
    //如果此方法一直调， 说明在查找服务或者特征是一直失败的，说明有问题，做出处理
    self.scanCount = 0 ;
    if (self.scanCount >= 15) {
        if (self.DisconnectedCallback) {
            self.DisconnectedCallback(self,DisconnectTypeSeriousProblem);
            return ;
        }
    }
    self.scanCount++ ;
    
    NSArray *connectedDevicesArr = [self.manager retrieveConnectedPeripheralsWithServices:@[self.serviceUUID,self.writeUUID]];
    //    NSLog(@"222ConnectedPeripherals===%@ %@  ",connectedDevicesArr,self.manager.islink);
    
    [connectedDevicesArr enumerateObjectsUsingBlock:^(CBPeripheral *obj, NSUInteger idx, BOOL *stop) {
        //连接首个被连接的设备（一般只有一个设备被系统连接上）
        NSLog(@"连接=====%@ %lu   \n%@",obj,(unsigned long)idx,obj.services);
        [self.manager cancelPeripheralConnection:obj];
        //利用中心将设备连接起来，并确保设备没被本APP连接
        if (obj.state == CBPeripheralStateDisconnected && idx == 0) {
            obj.delegate = self;
            [self.manager connectPeripheral:obj options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:TRUE]}];
            
        }
        
    }];
    [self.manager stopScan];
    
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}
- (void)stopScan
{
    [self.manager stopScan];
}
- (void)writeDataToBlueTooth
{
    if (self.currentSendOrder.length == 0) {
        return ;
    }
    if (nil == self.writeCharacteristic || nil == self.peripheral) {
        [self scan];
        return ;
    }
    
    [self.peripheral writeValue:self.currentSendOrder
              forCharacteristic:self.writeCharacteristic
                           type:CBCharacteristicWriteWithResponse];
    
}

#pragma mark - systemAPI callback
//系统蓝牙状态发生改变
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self scan];
            break;
        case CBCentralManagerStatePoweredOff:
            if (self.DisconnectedCallback) {
                self.DisconnectedCallback(self,DisconnectTypeSystemNoOpen);
            }
            break ;
        default:
            break ;
    }
}
//蓝牙发现一个设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"蓝牙发现一个设备 %@(%@) uuid = %@",peripheral.name,RSSI ,peripheral.identifier.UUIDString);
    
    
    if (peripheral.identifier) {
        // Retrieve already known devices
        [self.manager retrievePeripheralsWithIdentifiers:@[peripheral.identifier]];
    }
    else {
        NSLog(@"Peripheral UUID is null");
        [self.manager connectPeripheral:peripheral options:nil];
//        [self startConnectionTimeoutMonitor:aPeripheral];
    }
#warning ========
    
    NSRange range = [peripheral.name rangeOfString:self.hardWareName];
    if (range.location != NSNotFound && peripheral.name.length>0){
        
        //后面12位作为显示的uuid
        NSString *uuid =  peripheral.identifier.UUIDString ;
        NSString *userUUID = [uuid substringFromIndex:uuid.length-12];
        //如果是查找设备，就直接加入数组
        if (self.currentUUID.length == 0) {
            [self.scanedDevicesSet addObject:userUUID];
        }
        //如果equipmentUUID 不为空，说明是连接设备
        else{
            //说明找到了这个设备
            if ([userUUID isEqualToString:self.currentUUID]) {
                
                [self stopScan];
                self.peripheral = peripheral ;
                [self.manager connectPeripheral:self.peripheral options:nil];
                
                if (self.StateChangedCallback) {
                    self.StateChangedCallback(self,StateTypeFindDevice);
                }
                
                [self stopScan];
            }
        }
    }
    
    //扫描10s后，如果还没有找到设备就通知控制器。
    if (self.scanDevicesCallback) {
        [self performSelector:@selector(shouldStopSearch) withObject:nil afterDelay:10.0];
    }
    
}

- (void)shouldStopSearch
{
    if (self.DisconnectedCallback) {
        self.DisconnectedCallback(self,DisconnectTypeNotFind);
    }
}
//设备连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"已经连接上了设备：%@",peripheral.name);
    [self stopScan];
    
    if (self.StateChangedCallback) {
        self.StateChangedCallback(self,StateTypeFindDevice);
    }
    
    peripheral.delegate = self ;
    [peripheral discoverServices:nil];
}
//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //iOS的框架自带重连机制，千万不要因为设备断开就手动调用立马扫描，不要扫描，不要扫描。具体看
    NSLog(@"连接失败:（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    
    if (self.DisconnectedCallback) {
        self.DisconnectedCallback(self,DisconnectTypeConnectFaild);
    }
    
}
//设备失去连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"失去连接:（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    if (self.DisconnectedCallback) {
        self.DisconnectedCallback(self,DisconnectTypeConnectBreak);
    }
}

//设备发现一个服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"发现服务失败：%@",error);
        [self performSelector:@selector(scan) withObject:nil afterDelay:0.5];
        return ;
    }
    
    NSLog(@"***************所有服务***************\n");
    for (CBService *service in peripheral.services) {
        NSLog(@"%@\n",service.UUID);
        if ([service.UUID isEqual:self.serviceUUID]) {
            self.service = service ;
            
            if (self.StateChangedCallback) {
                self.StateChangedCallback(self,StateTypeFindService);
            }
            
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
//发现了服务里的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"发现特征失败：%@",error);
        [self performSelector:@selector(scan) withObject:nil afterDelay:0.5];
        return ;
    }
    
    NSLog(@"***************所需服务里面的所有特征***************\n");
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        
        if ([characteristic.UUID isEqual:self.notifyUUID]) {
            
            //血氧
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0xFFE1"]]) {
                
                
            }
            
            self.notifyCharacteristic = characteristic ;
            //监听特征端口返回值，在setNotifyValue:forCharacteristic中返回数据
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            //发现特征的描述 搜索Characteristic的Descriptors
            //在peripheral:didDiscoverDescriptorsForCharacteristic:error中返回数据
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
            
            if (self.StateChangedCallback) {
                self.StateChangedCallback(self,StateTypeFindcharacteristic);
            }
        }
        
        
        if ([characteristic.UUID isEqual:self.writeUUID]) {
            self.writeCharacteristic = characteristic ;
            //从这个特征中读数据。在peripheral:didUpdateValueForCharacteristic:error中返回数据
            [self.peripheral readValueForCharacteristic:characteristic];
            
            [self writeDataToBlueTooth];
        }
    }
}


- (void)setBlueToothType:(NSInteger)blueToothType
{
    _blueToothType = blueToothType ;
    
    switch (blueToothType) {
        case BlueToothTypeBloodPressure:{
            self.serviceUUID =[CBUUID UUIDWithString:@"0xFFF0"] ;
            self.writeUUID= [CBUUID UUIDWithString:@"0xFFF1"] ;
            self.notifyUUID =[CBUUID UUIDWithString:@"0xFFF2"];
            self.hardWareName = @"SZLSD SPPLE Module" ;
            self.saveDefaultUUID = @"pressure_uuid";
        }break;
        case BlueToothTypeUrine:{
            self.serviceUUID =[CBUUID UUIDWithString: @"0xFFF0"] ;
            self.writeUUID= [CBUUID UUIDWithString:@"0xFFF1"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFFF1"];
            self.hardWareName = @"LanQianTech";
            self.saveDefaultUUID = @"urineTest_uuid";
        }break;
        case BlueToothTypeOxygen:{
            self.serviceUUID =[CBUUID UUIDWithString: @"0xFFE0"] ;
            self.writeUUID= [CBUUID UUIDWithString:@"0xFFE1"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFFE1"];
            self.hardWareName = @"BLT_M70C";
            self.saveDefaultUUID = @"oxygen_uuid";
        }break;
        case BlueToothTypeWeight:{
            self.serviceUUID = [CBUUID UUIDWithString:@"0xFFF0"] ;
            self.writeUUID=[CBUUID UUIDWithString:@"0xFFF1"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFFF4"];
            self.hardWareName = @"Electronic Scale" ;
            self.saveDefaultUUID = @"weight_uuid";
        }break;
        case BlueToothTypeBloodSugar:{
            self.serviceUUID = [CBUUID UUIDWithString:@"0xFC00"] ;
            self.writeUUID= [CBUUID UUIDWithString:@"0xFCA0"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFCA1"];
            self.hardWareName = @"ClinkBlood" ;
            self.saveDefaultUUID = @"sugar_uuid";
        }break;
        case BlueToothTypeTemperature:{
            self.serviceUUID = [CBUUID UUIDWithString:@"0xFC00" ];
            self.writeUUID= [CBUUID UUIDWithString:@"0xFCA0"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFCA1"];
            self.hardWareName = @"ClinkBlood" ;
            self.saveDefaultUUID = @"temp_uuid";
        }break;
        case BlueToothTypeSweat:{
            self.serviceUUID = [CBUUID UUIDWithString:@"0xFFE0" ];
            self.writeUUID= [CBUUID UUIDWithString:@"0xFFE1"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFFE1"];
            self.hardWareName = @"NFSMA" ;
            self.saveDefaultUUID = @"sweat_uuid";
        }break ;
        default:
            NSAssert(NO, @"your should set up a heardwaretype");
            
            self.serviceUUID = [CBUUID UUIDWithString:@"0xFFF0"] ;
            self.writeUUID= [CBUUID UUIDWithString:@"0xFFF1"] ;
            self.notifyUUID = [CBUUID UUIDWithString:@"0xFFF2"];
            self.hardWareName = @"Null" ;
            break;
    }
}

#pragma mark - getter

- (CBCentralManager *)manager
{
    if (nil == _manager ) {
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return _manager ;
}
- (NSMutableSet *)scanedDevicesSet
{
    if (nil == _scanedDevicesSet) {
        _scanedDevicesSet = [NSMutableSet setWithCapacity:5];
    }
    return _scanedDevicesSet ;
}

#pragma mark - 下面方法可以不用实现
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

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"00000000000000 uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"111111%@\n%@\n",central,peripherals);
    
}
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    
    NSLog(@"2222222%@\n%@",peripherals,central);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error){
        NSLog(@"3333333333\n%@\n%@\n%@ \n\n\n",peripheral,error,characteristic);
    }
    
}
// 当写入某个特征值后 外设代理执行的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error){
        NSLog(@"4444444444%@\n%@\n%@ \n\n\n",characteristic,peripheral,error);
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error){
        NSLog(@"555555555%@\n%@\n%@  \n\n\n",characteristic,peripheral,error);
        
    }
}


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    NSLog(@"6666666 %@",peripheral);
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"777777777  %@ \n %@",peripheral,error);
}
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"888888888888%@  %@ \n%@",peripheral,RSSI,error);
}
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    NSLog(@"999999999999  %@",peripheral);
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"100000000000%@ \n%@",invalidatedServices,peripheral);
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    NSLog(@"11------111-------111\n%@ \n %@ \n %@",peripheral,descriptor,error);
}

@end
