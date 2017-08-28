//
//  ExampleDetailViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/24.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleDetailViewController.h"

#import "EasyUtils.h"   

@interface ExampleDetailViewController ()

@property (nonatomic,strong)NSString *seriveUUID ;
@property (nonatomic,strong)NSString *writeUUID ;
@property (nonatomic,strong)NSString *readUUID ;

@property (nonatomic,strong) EasyPeripheral *perpheral ;
@property (nonatomic,strong) EasyBlueToothManager  *bleManager ;

@end

@implementation ExampleDetailViewController

- (void)dealloc
{
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
//    kWeakSelf(self)
//    [self.bleManager scanAndConnectDeviceWithName:@"BLT_M70C" callback:^(EasyPeripheral *peripheral, NSError *error) {
//        weakself.peripheral = peripheral ;
//    }];
    
    [self.bleManager connectDeviceWithName:@"BLT_M70C" serviceUUID:@"0xFFE0" notifyUUID:@"0xFFE1" wirteUUID:@"0xFFE1" writeData:nil callback:^(NSData *data, NSError *error) {
        NSLog(@"%@ -- %@",data ,error );
    }];
    
}




- (EasyBlueToothManager *)bleManager
{
    if (nil == _bleManager) {
        _bleManager = [EasyBlueToothManager shareInstance];
        
        dispatch_queue_t queue = dispatch_queue_create("com.easyBluetooth.queue", 0);
        NSDictionary *managerDict = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
        NSDictionary *scanDict = @{};
        NSDictionary *connectDict = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
        
        EasyManagerOptions *options = [[EasyManagerOptions alloc]initWithManagerQueue:queue managerDictionary:managerDict scanOptions:scanDict scanServiceArray:nil connectOptions:connectDict];
        options.scanTimeOut = 10 ;
        options.connectTimeOut = 5 ;
        
        _bleManager.managerOptions = options ;
        
    }
    
    return _bleManager ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
