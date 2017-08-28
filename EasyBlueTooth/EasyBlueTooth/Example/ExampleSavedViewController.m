//
//  ExampleSavedViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/28.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleSavedViewController.h"

#import "BindingDeviceView.h"
#import "EFShowView.h"

static NSString *const savedUUID = @"saveuuid" ;

@interface ExampleSavedViewController ()<BindingDeviceViewProtocol>

@end

@implementation ExampleSavedViewController

- (void)dealloc
{
    [self.bleManager disconnectAllPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"设备保存到本地";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *saveduuid = EFUserDefaultsObjForKey(savedUUID) ;
    
    if (saveduuid) {
        
    }
    else{
        [self.bleManager scanAllDeviceWithName:@"NFHY" callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
            
            BindingDeviceView *view = [BindingDeviceView BindingDeviceViewDelegate:self name:@"血糖仪" dataArray:deviceArray];
            [self.view addSubview:view];
        }];
    }
    // Do any additional setup after loading the view.
}

- (void)BindingDeviceViewSure:(BindingDeviceView *)view device:(NSString *)device
{
//    self.sysBlueTooth.saveUUID = device ;
    [EFShowView showSueecssText:@"设备绑定成功" ];
}
- (void)BindingDeviceViewCancel:(BindingDeviceView *)view
{
    
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
