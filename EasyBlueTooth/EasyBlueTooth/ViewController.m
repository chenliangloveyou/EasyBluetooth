//
//  ViewController.m
//  EasyBlueTooth
//
//  Created by nf on 16/3/16.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ViewController.h"

#import "EasyBlueToothManager.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *findDevices;
@property (weak, nonatomic) IBOutlet UIButton *connectDevice;

@end

@implementation ViewController

- (void)dealloc
{
}
- (IBAction)findDevices:(id)sender {
    
//  [[EasyBlueToothManager shareInstance]searchDeviceWithName:@"hxsb" timeInterval:5 callBack:^(EasyPeripheral *peripheral) {
//     [[EasyBlueToothManager shareInstance]connectDeviceWihtPeripheral:peripheral callback:^(NSError *error) {
//         if (nil == error) {
//             [[EasyBlueToothManager shareInstance]writeDataWithPeripheral:peripheral data:nil writeUUID:@"0xff01" callback:^(NSData *data, NSError *error) {
//                 [[EasyBlueToothManager shareInstance] notifyDataWithPeripheral:peripheral notifyUUID:@"ff01" withCallback:^(NSData *data, NSError *error) {
//                     if (data) {
//                         NSLog(@"%@",data);
//                     }
//                 }];
//             }];
//         }
//     }];
//  }];
    
}
- (IBAction)connectDevice:(id)sender {
    
   
    //[self.sysBlueTooth connectDeviceWithUUID:nil orderType:0 sweatRate:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
