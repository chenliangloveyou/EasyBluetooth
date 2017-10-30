//
//  ExampleScanNameViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/28.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleScanNameViewController.h"

#import "EFShowView.h"

@interface ExampleScanNameViewController ()

@property (nonatomic,strong) EasyPeripheral *peripheral ;

@end

@implementation ExampleScanNameViewController

- (void)dealloc
{
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫描设备名称";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.bleManager.bluetoothStateChanged = ^(EasyPeripheral *peripheral, bluetoothState state) {
        queueMainStart
        switch (state) {
            case bluetoothStateSystemReadly:
                [EFShowView showInfoText:@"蓝牙已准备就绪.." ];
                break;
            case bluetoothStateDeviceFounded:
                [EFShowView showInfoText:@"已发现设备"];
                break ;
                case bluetoothStateDeviceConnected:
                [EFShowView showInfoText:@"设备连成功"];
            default:
                break;
        }
        queueEnd
    };
    
    [EFShowView showInfoText:@"正在扫描并连接设别..."];
    kWeakSelf(self)
    [self.bleManager scanAndConnectDeviceWithName:@"SZLSD SPPLE Module" callback:^(EasyPeripheral *peripheral, NSError *error) {
        if (!error) {
            weakself.peripheral = peripheral ;            
        }
    }];
    
    
    UIButton *button  =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor redColor]];
    [button setFrame:CGRectMake(200, 200, 50, 50)];
    [button addTarget:self action:@selector(sendOrder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)sendOrder
{
    Byte bytes[6]= {0xfe ,0x81,0x00,0x00,0x00,0x01};
    NSData *D = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    [self.bleManager notifyDataWithPeripheral:self.peripheral serviceUUID:@"0xFFF0" notifyUUID:@"0xFFF2" notifyValue:YES withCallback:^(NSData *data, NSError *error) {
        NSLog(@"%@ -- %@",data ,error );
    }];
    QueueStartAfterTime(0.5)
    [self.bleManager writeDataWithPeripheral:self.peripheral serviceUUID:@"0xFFF0" writeUUID:@"0xFFF1" data:D callback:^(NSData *data, NSError *error) {
        NSLog(@"%@ -- %@",data ,error );
    }];
    queueEnd
}
- (void)test
{
    [self.bleManager notifyDataWithPeripheral:self.peripheral serviceUUID:@"0xFFE0" notifyUUID:@"0xFFE1" notifyValue:YES withCallback:^(NSData *data, NSError *error) {
        NSLog(@"%@ -- %@",data ,error );
    }];
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
