//
//  ExampleScanRuleViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/28.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleScanRuleViewController.h"
#import "EFShowView.h"
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
    
    [EFShowView showHUDMsg:@"正在扫描设备"];
    [self.bleManager scanAllDeviceAsyncWithRule:^BOOL(EasyPeripheral *peripheral) {
        return  peripheral.name.length > 5 ;
    } callback:^(EasyPeripheral *peripheral, searchFlagType searchFlagType, NSError *error) {
        NSLog(@"%@ == %lu == %@",peripheral,(unsigned long)searchFlagType ,error) ;
    }];
   
//    [self.bleManager scanDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
//        
//        return peripheral.name.length > 0 ;
//        
//    } callback:^(EasyPeripheral *peripheral, NSError *error) {
//        
//        queueMainStart
//        [EFShowView HideHud];
//
//        if (!error) {
//            //把peripheral 保存起来。 用来操作数据
//            [EFShowView showSueecssText:@"设备连接成功!"];
//        }
//        else{
//            [EFShowView showErrorText:error.domain];
//        }
//        queueEnd
//
//    }];
    
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
