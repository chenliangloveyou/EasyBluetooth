//
//  ToolInputView.m
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/20.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolInputView.h"
#import "EasyUtils.h"
#import "UIView+Ext.h"

@interface ToolInputView()

@property (nonatomic,strong)inputViewCallback callback ;

@property (nonatomic,strong)UIView *bgView ;
@property (nonatomic,strong)UIView *inputView ;
@property (nonatomic,strong)UIButton *sureButton ;
@property (nonatomic,strong)UITextField *inputTextField ;

@end

@implementation ToolInputView

- (void)dealloc
{

}
+ (instancetype)toolInputViewWithCallback:(inputViewCallback)callback
{
    ToolInputView *view = [[ToolInputView alloc]initWithFrame:CGRectZero];
    view.callback = [callback copy];
    return view ;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [[UIApplication sharedApplication].keyWindow addSubview:bgView];
        self.bgView = bgView ;
        
        [bgView addSubview:self.inputView];
        [self.inputView addSubview:self.inputTextField];
        [self.inputView addSubview:self.sureButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [self.inputTextField becomeFirstResponder];

    }
    return self ;
}
-(void)keyboardWillAppear:(NSNotification *)notification
{//(origin = (x = 0, y = 451), size = (width = 375, height = 216))
    CGRect keyboardEndingUncorrectedFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect keyboardEndingFrame = [self convertRect:keyboardEndingUncorrectedFrame fromView:nil];
    
    self.inputView.top = SCREEN_HEIGHT-self.inputView.height-keyboardEndingFrame.size.height ;
}
- (void)sureButtonClick
{
    if (_callback) {
        _callback(self.inputTextField.text);
    }
    
    [self.bgView removeFromSuperview];
    self.bgView = nil;
}

#pragma mark - getter 

- (UIView *)inputView
{
    if (nil == _inputView) {
        _inputView  =[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 50)];
        _inputView.backgroundColor = [UIColor whiteColor];
    }
    return _inputView;
}
- (UITextField *)inputTextField
{
    if (nil == _inputTextField) {
        _inputTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 90, 30)];
        _inputTextField.placeholder = @"请输入...";
    }
    return _inputTextField ;
}
- (UIButton *)sureButton
{
    if (nil == _sureButton) {
        _sureButton  =[UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setFrame:CGRectMake(SCREEN_WIDTH-80, 5, 70, 40)];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_sureButton setBackgroundColor:[UIColor blueColor]];
        
    }
    return _sureButton ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
