//
//  ToolDetailHeaderCell.h
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^buttonClickCallback)(BOOL isShow);

@interface ToolDetailHeaderCell : UITableViewHeaderFooterView

@property (nonatomic,strong)NSString *serviceName ;
@property (nonatomic,assign)NSInteger sectionState ;//是否是第一行，用来隐藏按钮
@property (nonatomic,copy)buttonClickCallback callback ;

+ (CGFloat)cellHeight ;

@end
