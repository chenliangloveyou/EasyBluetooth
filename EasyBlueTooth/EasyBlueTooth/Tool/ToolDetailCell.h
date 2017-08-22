//
//  ToolDetailCell.h
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyCharacteristic.h"
@interface ToolDetailCell : UITableViewCell
@property (nonatomic,strong)EasyCharacteristic *character ;
//@property (nonatomic,strong)
@property (nonatomic,strong)NSString *titleString ;
@property (nonatomic,strong)NSString *subTitleString ;

+ (CGFloat)cellHeight ;


@end
