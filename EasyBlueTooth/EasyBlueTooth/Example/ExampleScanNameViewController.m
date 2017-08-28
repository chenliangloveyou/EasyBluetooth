//
//  ExampleScanNameViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/28.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleScanNameViewController.h"

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
    
    kWeakSelf(self)
    [self.bleManager scanAndConnectDeviceWithName:@"BLT_M70C" callback:^(EasyPeripheral *peripheral, NSError *error) {
        if (!error) {
            
            weakself.peripheral = peripheral ;
            
        }
    }];
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
