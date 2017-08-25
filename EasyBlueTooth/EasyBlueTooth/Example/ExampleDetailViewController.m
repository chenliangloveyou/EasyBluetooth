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
    
    [[EasyBlueToothManager shareInstance] connectDeviceWithName:@"NFHY" timeout:10 callback:^(EasyPeripheral *peripheral, NSError *error) {
       
        if (!error) {
            NSArray *tempArray = @[[CBUUID UUIDWithString:self.seriveUUID]];
            [peripheral discoverDeviceServiceWithUUIDArray:tempArray callback:^(EasyPeripheral *peripheral, NSArray<EasyService *> *serviceArray, NSError *error) {
               
                if (!error) {
                    for (EasyService *tempService in serviceArray) {
                        
                        CBUUID *writeUUID = [CBUUID UUIDWithString:self.writeUUID];
                        CBUUID *notifyUUID= [CBUUID UUIDWithString:self.readUUID];
                        NSArray *tempArr = @[writeUUID,notifyUUID];
                        [tempService discoverCharacteristicWithCharacteristicUUIDs:tempArr callback:^(NSArray<EasyCharacteristic *> *characteristics, NSError *error) {
                            
                        }];
                    }
                }
                
            }];
        }
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
