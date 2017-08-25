//
//  EFShowView.h
//  EFHealth
//
//  Created by nf on 16/7/20.
//  Copyright © 2016年 ef. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, ShowStatus) {
    
    ShowSuccess, /** 成功 */
    ShowError,   /** 失败 */
    ShowInfo,    /** 提示 */
    ShowScore,   /** 积分 */
};

typedef void(^alertMessageCallback)(void);


@interface EFShowView : UIView

+ (instancetype)showStatus:(ShowStatus)status text:(NSString *)text InView:(UIView *)view;
+ (instancetype)showStatus:(ShowStatus)status text:(NSString *)text ;

/** 只显示文字 */
+ (instancetype)showText:(NSString *)text ;

/** 成功 */
+ (instancetype)showSuccessView:(UIView *)view text:(NSString *)text ;
+ (instancetype)showSueecssText:(NSString *)text ;
 /** 提示 */
+ (instancetype)showInfoView:(UIView *)view text:(NSString *)text ;
+ (instancetype)showInfoText:(NSString *)text ;
 /** 失败 */
+ (instancetype)showErrorView:(UIView *)view text:(NSString *)text ;
+ (instancetype)showErrorText:(NSString *)text ;
 /** 积分 */
+ (instancetype)showScoreText:(NSString *)text ;

+ (void)showAlertMessageWithTitle:(NSString *)title contentMessage:(NSString *)contentMessage cancelTitle:(NSString *)cancelTitle cancelCallBack:(alertMessageCallback)cancel sureTitle:(NSString *)sureTitle sureCallBack:(alertMessageCallback)sure ;


#pragma mark - hud
+ (void)showHUDMsg:(NSString *)msg ;


+ (void)showHUDInView:(UIView *)view;

+ (void)showHUDInView:(UIView *)view msg:(NSString *)msg;

+ (void)HideHud;

@end















