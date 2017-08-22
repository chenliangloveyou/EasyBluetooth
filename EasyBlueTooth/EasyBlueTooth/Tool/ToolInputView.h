//
//  ToolInputView.h
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/20.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^inputViewCallback)(NSString *number);


@interface ToolInputView : UIView

+ (instancetype)toolInputViewWithCallback:(inputViewCallback)callback ;


@end
