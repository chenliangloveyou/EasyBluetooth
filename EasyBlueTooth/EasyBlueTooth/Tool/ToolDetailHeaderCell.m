//
//  ToolDetailHeaderCell.m
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolDetailHeaderCell.h"

#import "EasyUtils.h"

@interface ToolDetailHeaderCell()

@property (nonatomic,strong)UILabel *serviceNameLabel ;
@property (nonatomic,strong)UIButton *showButton ;

@end
@implementation ToolDetailHeaderCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        
        self.backgroundView = nil;
        self.contentView.backgroundColor = [UIColor clearColor] ;
        
//        [self buildUI];
    }
    return self ;
}
- (void)setServiceName:(NSString *)serviceName
{
    _serviceName = serviceName ;
    self.serviceNameLabel.text  =serviceName ;
}
- (void)setSectionState:(NSInteger)sectionState
{
    _sectionState = sectionState ;
    self.showButton.hidden = sectionState==-1  ;
    
    if (sectionState) {
        [self.showButton setTitle:@"隐藏" forState:UIControlStateNormal];
    }
    else{
        [self.showButton setTitle:@"显示" forState:UIControlStateNormal];
    }
}
- (void)showButtonClick:(UIButton *)button
{
    if (_callback) {
        _callback([button.titleLabel.text isEqualToString:@"显示"]);
    }
}
- (UILabel *)serviceNameLabel
{
    if (nil == _serviceNameLabel) {
        _serviceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, [ToolDetailHeaderCell cellHeight])];
        _serviceNameLabel.textColor = [UIColor lightGrayColor];
        _serviceNameLabel.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:_serviceNameLabel];
    }
    return _serviceNameLabel ;
}
- (UIButton *)showButton
{
    if (nil == _showButton) {
        _showButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [_showButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_showButton addTarget:self action:@selector(showButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_showButton setTitle:@"展开" forState:UIControlStateNormal];
        [_showButton setFrame:CGRectMake(SCREEN_WIDTH-60, 10, 50, 30)];
        [self.contentView addSubview:_showButton ];
    }
    return _showButton ;
}
+ (CGFloat)cellHeight
{
    return 50 ;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
