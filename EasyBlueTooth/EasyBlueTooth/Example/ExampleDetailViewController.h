//
//  ExampleDetailViewController.h
//  EasyBlueTooth
//
//  Created by nf on 2017/8/24.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyPeripheral.h"
#import "EasyBlueToothManager.h"

@interface ExampleDetailViewController : UIViewController

@property (nonatomic,strong)EasyPeripheral *peripheral ;
@property (nonatomic,strong)NSArray <EasyPeripheral *>*deviceArray ;
@end
