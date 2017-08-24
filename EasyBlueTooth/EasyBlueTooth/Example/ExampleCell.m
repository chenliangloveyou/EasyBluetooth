//
//  ExampleCell.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleCell.h"

@interface ExampleCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ExampleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString ;
    _titleLabel.text = titleString ;
}
+ (CGFloat)cellHieght
{
    return 60 ;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
