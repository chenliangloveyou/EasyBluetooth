//
//  BindingDeviceView.h
//  EFHealth
//
//  Created by nf on 16/3/18.
//  Copyright © 2016年 ef. All rights reserved.
//

#import "UIView+Ext.h"

@class BindingDeviceView ;

@protocol BindingDeviceViewProtocol <NSObject>

- (void)BindingDeviceViewCancel:(BindingDeviceView *)view ;
- (void)BindingDeviceViewSure:(BindingDeviceView *)view device:(NSString *)device;

@end


@interface BindingDeviceView : UIView

+ (instancetype)BindingDeviceViewDelegate:(id<BindingDeviceViewProtocol>)Delegate dataArray:(NSArray *)dataArray ;


@end
