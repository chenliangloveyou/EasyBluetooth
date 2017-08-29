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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"解绑设备" style:UIBarButtonItemStylePlain target:self action:@selector(barbuttonClick)];
    self.navigationItem.rightBarButtonItem = item ;
    
    NSString *saveduuid = EFUserDefaultsObjForKey(savedUUID) ;
    kWeakSelf(self)
    if (!ISEMPTY(saveduuid)) {
        [weakself connectDevices];
    }
    else{
        
        [EFShowView showHUDMsg:@"寻找设备中..."] ;
        [self.bleManager scanAllDeviceWithName:@"NFHY" callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
          
            queueMainStart
            [EFShowView HideHud];
            
            if (deviceArray.count) {
                BindingDeviceView *view = [BindingDeviceView BindingDeviceViewDelegate:self dataArray:deviceArray];
                [weakself.view addSubview:view];
            }
            else{
                [EFShowView showInfoText:@"没搜索到设备..."];
            }
            queueEnd
        }];
    }
    // Do any additional setup after loading the view.
}
-(void)barbuttonClick
{
    EFUserDefaultsSetObj(@"", savedUUID);
    [EFShowView showSueecssText:@"解绑成功"];
}
- (void)BindingDeviceViewSure:(BindingDeviceView *)view device:(NSString *)device
{
//    self.sysBlueTooth.saveUUID = device ;
    EFUserDefaultsSetObj(device, savedUUID);
    [self connectDevices];
    
    queueMainStart
    [EFShowView showSueecssText:@"设备绑定成功" ];
    queueEnd
    
}
- (void)BindingDeviceViewCancel:(BindingDeviceView *)view
{

}

- (void)connectDevices
{
    NSString *unsavedUUID = EFUserDefaultsObjForKey(savedUUID);
    [EFShowView showHUDMsg:@"正在连接设备..."];
    [self.bleManager connectDeviceWithIdentifier:unsavedUUID callback:^(EasyPeripheral *peripheral, NSError *error) {
        queueMainStart
        [EFShowView showSueecssText:@"设备连接成功"];
        [EFShowView HideHud];
        queueEnd
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
