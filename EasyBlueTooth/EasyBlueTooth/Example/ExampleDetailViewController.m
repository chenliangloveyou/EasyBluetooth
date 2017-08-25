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

@end

@implementation ExampleDetailViewController

- (void)dealloc
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    EasyPeripheral *p = self.deviceArray.firstObject ;
    self.seriveUUID = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
    CBUUID *uuid = [CBUUID UUIDWithString:self.seriveUUID];
    [p discoverDeviceServiceWithUUIDArray:@[uuid] callback:^(EasyPeripheral *peripheral, NSArray<EasyService *> *serviceArray, NSError *error) {
       
        for (EasyService *tempS in serviceArray) {
            CBUUID *uui  = [CBUUID UUIDWithString:self.writeUUID];
            CBUUID *uuis = [CBUUID UUIDWithString:self.readUUID];
            [tempS discoverCharacteristicWithCharacteristicUUIDs:@[uui,uuis] callback:^(NSArray<EasyCharacteristic *> *characteristics, NSError *error) {
                
            }];
        }
        queueMainStart
        NSLog(@"==============%@",serviceArray);
        queueEnd
        
    }];
    // Do any additional setup after loading the view.
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
