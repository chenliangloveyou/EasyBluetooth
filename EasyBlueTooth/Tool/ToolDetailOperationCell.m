//
//  ToolDetailOperationCell.m
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/19.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolDetailOperationCell.h"
#import "UIView+Ext.h"

@interface ToolDetailOperationCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
@implementation ToolDetailOperationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setTitle:(NSString *)title
{
    _title = title ;
    self.titleLabel.text = [NSString stringWithFormat:@"%@",title] ;
}
- (void)setIsOperation:(BOOL)isOperation
{
    _isOperation = isOperation ;
    
    self.titleLabel.textColor = isOperation ? [UIColor blueColor] : [UIColor darkTextColor];
    
}
+ (CGFloat)cellHeight
{
    return 44 ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
