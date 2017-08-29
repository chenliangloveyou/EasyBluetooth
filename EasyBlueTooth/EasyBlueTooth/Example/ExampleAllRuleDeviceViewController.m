//
//  ExampleAllRuleDeviceViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/29.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleAllRuleDeviceViewController.h"

@interface ExampleAllRuleDeviceViewController ()

@property (nonatomic,strong)NSMutableArray *connectArray ;
@end

@implementation ExampleAllRuleDeviceViewController

- (void)dealloc
{
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.bleManager scanAndConnectAllDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
        return peripheral.name.length > 5 ;
    } callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
        
        for (EasyPeripheral *tempP in deviceArray) {
            if (!tempP.connectErrorDescription) {
                [self.connectArray addObject:tempP];
            }
        }
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
