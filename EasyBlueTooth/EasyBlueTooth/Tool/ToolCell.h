//
//  ToolCell.h
//  EasyBlueTooth
//
//  Created by nf on 2017/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EasyPeripheral.h"

@interface ToolCell : UITableViewCell

@property (nonatomic,strong)EasyPeripheral *peripheral ;

+ (CGFloat)cellHeight ;

@end
