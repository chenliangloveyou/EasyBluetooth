//
//  EFShowView.m
//  EFHealth
//
//  Created by nf on 16/7/20.
//  Copyright © 2016年 ef. All rights reserved.
//

#import "EFShowView.h"
#import "EasyUtils.h"

@interface EFShowView()<CAAnimationDelegate>
{
    ShowStatus _showStatus ;
    NSString *_text ;
    
}
@property (nonatomic,assign)ShowStatus showStatus;

@end

@implementation EFShowView
- (void)dealloc
{

}
+ (instancetype)showText:(NSString *)text
{
    EFShowView *efShowView = [[self alloc]init];
    
    if (!text.length) {
        return efShowView ;
    }
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(230, 100)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                     context:nil];
    
    UIView *showView =[[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-rect.size.width-40)/2, 200, rect.size.width+40, rect.size.height+30)];
    showView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:showView] ;
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15,rect.size.width, rect.size.height)];
    label.text = text ;
    label.textAlignment = NSTextAlignmentCenter ;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 0 ;
    [showView addSubview:label];
    
    
    showView.alpha = 0.1 ;
    [UIView animateWithDuration:0.3 animations:^{
        showView.alpha = 1.0 ;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:(1+text.length*0.1) animations:^{
            showView.alpha = 0.9 ;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                showView.alpha = 0.1 ;
            } completion:^(BOOL finished) {
                [showView removeFromSuperview];
            }];
            
        }];
    }];
    
    return efShowView ;
}

/** 成功 */
+ (instancetype)showSuccessView:(UIView *)view text:(NSString *)text
{
    return [EFShowView showStatus:ShowSuccess text:text InView:view];
}
+ (instancetype)showSueecssText:(NSString *)text
{
    return [EFShowView showInfoView:[UIApplication sharedApplication].keyWindow text:text];
}
/** 提示 */
+ (instancetype)showInfoView:(UIView *)view text:(NSString *)text
{
    return [EFShowView showStatus:ShowInfo text:text InView:view];
}
+ (instancetype)showInfoText:(NSString *)text
{
    return [EFShowView showInfoView:[UIApplication sharedApplication].keyWindow text:text];
}
/** 失败 */
+ (instancetype)showErrorView:(UIView *)view text:(NSString *)text
{
    return [EFShowView showStatus:ShowError text:text InView:view];
}
+ (instancetype)showErrorText:(NSString *)text
{
    return [EFShowView showErrorView:[UIApplication sharedApplication].keyWindow text:text];
}
/** 积分 */
+ (instancetype)showScoreText:(NSString *)text
{
    return [EFShowView showStatus:ShowScore text:text InView:[UIApplication sharedApplication].keyWindow];
}


+ (instancetype)showStatus:(ShowStatus)status text:(NSString *)text
{
    return [EFShowView showStatus:status text:text InView:[UIApplication sharedApplication].keyWindow];
}
+ (instancetype)showStatus:(ShowStatus)status text:(NSString *)text InView:(UIView *)view
{
    if (nil == view) {
        return nil ;
    }
    EFShowView *efShowView = [[self alloc]init];
    efShowView.showStatus = status ;
    efShowView->_text = text ;
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(230, 100)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                     context:nil];
    if (rect.size.width < 130) {
        rect.size.width = 130 ;
    }
    if (rect.size.height < 40) {
        rect.size.height = 40 ;
    }
    
    CGFloat imageWH = status==ShowScore ? 40 : 30 ;
    
    UIView *showView =[[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-rect.size.width-40)/2, 200, rect.size.width+40, rect.size.height+40+imageWH)];
    showView.backgroundColor = [UIColor blackColor];
    [view addSubview:showView] ;

    NSString *imgName = @"";
    switch (status) {
        case ShowSuccess: imgName = @"hud_success";  break;
        case ShowError:   imgName = @"hud_error";  break;
        case ShowInfo:    imgName = @"hud_info";  break;
        case ShowScore:   imgName = @"hud_score"; break ;
        default:    break;
    }
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake((showView.frame.size.width-imageWH)/2, 20, imageWH, imageWH)];
    imageV.image = [UIImage imageNamed:imgName];
    [showView addSubview:imageV];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 30+imageWH,rect.size.width, rect.size.height)];
    label.text = text ;
    label.textAlignment = NSTextAlignmentCenter ;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 0 ;
    [showView addSubview:label];
    
    
    if (status == ShowScore) {
        
        CABasicAnimation *forwardAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        forwardAnimation.duration = 0.2;
        forwardAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5f :1.7f :0.6f :0.85f];
        forwardAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        forwardAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        
        CABasicAnimation *backwardAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        backwardAnimation.duration = 0.3;
        backwardAnimation.beginTime = forwardAnimation.duration + 2.0;
        backwardAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.15f :0.5f :-0.7f];
        backwardAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        backwardAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[forwardAnimation,backwardAnimation];
        animationGroup.duration = forwardAnimation.duration + backwardAnimation.duration + 2.0;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        
        [showView.layer addAnimation:animationGroup forKey:nil];
        
        [UIView animateWithDuration:5.0f animations:^{
            showView.alpha = 0.99;
        } completion:^(BOOL finished) {
            [showView removeFromSuperview];
        }];
    }
    else{
        
        showView.alpha = 0.1 ;
        [UIView animateWithDuration:0.3 animations:^{
            showView.alpha = 1.0 ;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:(text.length*0.1+1) animations:^{
                showView.alpha = 0.9 ;
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    showView.alpha = 0.1 ;
                } completion:^(BOOL finished) {
                    [showView removeFromSuperview];
                }];
                
            }];
        }];
    }
   
    
    
    return efShowView ;
}

+ (void)showAlertMessageWithTitle:(NSString *)title contentMessage:(NSString *)contentMessage cancelTitle:(NSString *)cancelTitle cancelCallBack:(alertMessageCallback)cancel sureTitle:(NSString *)sureTitle sureCallBack:(alertMessageCallback)sure
{
    NSAssert(cancelTitle.length, @"you should add a suretitle and sureCallback");
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:contentMessage preferredStyle:UIAlertControllerStyleAlert];
        
        if (sureTitle.length) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                dispatch_after(0.2, dispatch_get_main_queue(), ^{
                    if (sure) sure() ;
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            [alertController addAction:action];
        }
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            dispatch_after(0.2, dispatch_get_main_queue(), ^{
                if (cancel)  cancel() ;
                [alertController dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        [alertController addAction:action2];
        [[EasyUtils topViewController] presentViewController:alertController animated:YES completion:nil];
    }
    else{
        NSAssert(NO, @"UIAlertController can't support !") ;
    }
    
}

#pragma mark - hud

MBProgressHUD *hud ;
+ (void)showHUDMsg:(NSString *)msg
{
    [EFShowView showHUDInView:[UIApplication sharedApplication].keyWindow msg:msg];
}
+ (void)showHUDInView:(UIView *)view
{
    [EFShowView showHUDInView:view msg:@""];
}

+ (void)showHUDInView:(UIView *)view msg:(NSString *)msg
{
    [self HideHud];
    
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
   
    hud.labelText = msg;
    hud.cornerRadius = 5 ;
    [hud show:YES];
    hud.animationType = MBProgressHUDAnimationZoom ;
    
}

+ (void)HideHud
{
    if (hud) {
        [hud hide:YES afterDelay:0];
        hud = nil;
    }
}

@end
























