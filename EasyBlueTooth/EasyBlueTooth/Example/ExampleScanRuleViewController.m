//
//  ExampleScanRuleViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/28.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleScanRuleViewController.h"

@interface ExampleScanRuleViewController ()

@end

@implementation ExampleScanRuleViewController

- (void)dealloc
{
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"条件扫描设备名称";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [self.bleManager scanDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
        
        return peripheral.name.length > 4 ;
        
    } callback:^(EasyPeripheral *peripheral, NSError *error) {
        
        //把peripheral 保存起来。 用来操作数据
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
