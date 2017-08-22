//
//  ViewController.m
//  EasyBlueTooth
//
//  Created by nf on 17/3/16.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ViewController.h"

#import "CommonBlueTooth.h"

@interface ViewController ()

@property (nonatomic,strong)CommonBlueTooth *sysBlueTooth ;
@property (weak, nonatomic) IBOutlet UIButton *findDevices;
@property (weak, nonatomic) IBOutlet UIButton *connectDevice;

@end

@implementation ViewController

- (void)dealloc
{
    _sysBlueTooth = nil ;
}
- (IBAction)findDevices:(id)sender {
    
    
    //查找设备
    [self.sysBlueTooth scanDevicescallBack:^(BaseBlueTooth *blueTooth, NSArray *devices, NSError *error) {
        
    } disConnectedCallback:^(BaseBlueTooth *blueTooth, DisconnectType disConnectType) {
        
    }];
    
}
- (IBAction)connectDevice:(id)sender {
    
    [self.sysBlueTooth connectDeviceWithUUID:nil sendOrder:nil];
    
    //[self.sysBlueTooth connectDeviceWithUUID:nil orderType:0 sweatRate:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   
    
    self.sysBlueTooth.StateChangedCallback = ^(BaseBlueTooth *blueTooth ,StateType stateType){
       
    };
    self.sysBlueTooth.DisconnectedCallback = ^(BaseBlueTooth *blueTooth,DisconnectType disConnectType){
        
    };
    self.sysBlueTooth.receivedDataCallBack = ^(BaseBlueTooth *blueTooth,id receivedData){
        
    };
}

- (CommonBlueTooth *)sysBlueTooth
{
    if (nil == _sysBlueTooth) {
        _sysBlueTooth = [[CommonBlueTooth alloc]initWithBlueToothType:BlueToothTypeSweat];
    }
    return _sysBlueTooth ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
