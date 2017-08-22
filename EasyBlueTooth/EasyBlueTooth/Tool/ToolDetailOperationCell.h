//
//  ToolDetailOperationCell.h
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/19.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolDetailOperationCell : UITableViewCell

@property (nonatomic,assign)BOOL isOperation ;//是否是操作标志

@property (nonatomic,strong)NSString *title ;

+ (CGFloat)cellHeight ;
@end
