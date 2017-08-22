//
//  ToolDetailCell.m
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolDetailCell.h"

@interface ToolDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation ToolDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setTitleString:(NSString *)titleString
{
    self.titleLabel.text = titleString ;
}
- (void)setSubTitleString:(NSString *)subTitleString
{
    if ([subTitleString isKindOfClass:[NSArray class]]) {
        NSString *allString = @"" ;
        NSArray *tempArray = (NSArray *)subTitleString ;
        for (NSString *tempS in tempArray) {
            allString = [allString stringByAppendingString:[NSString stringWithFormat:@"%@ ",tempS]];
        }
        self.subTitleLabel.text = allString ;
    }else
    self.subTitleLabel.text  =[NSString stringWithFormat:@"%@",subTitleString] ;
}
- (void)setCharacter:(EasyCharacteristic *)character
{
    self.titleLabel.text = character.name ;
    self.subTitleLabel.text = [NSString stringWithFormat:@"Properties:%@",character.propertiesString] ;
}
+ (CGFloat)cellHeight
{
    return 55 ;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
