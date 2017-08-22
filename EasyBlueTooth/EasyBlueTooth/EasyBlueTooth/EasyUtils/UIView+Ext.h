//
//  UIView+Ext.h
//  HHMusic
//
//  Created by liumadu on 14-9-22.
//  Copyright (c) 2014年 hengheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Ext)

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat maxY;

@property(nonatomic,assign) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;
@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;
@property(nonatomic,readonly) CGRect screenFrame;

@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;

@property(nonatomic) BOOL visible;

/**
 *  给view添加边框
 *
 *  @param borderWidth  边框宽度
 *  @param cornerRadius 边框圆角半径
 *  @param borderColor  默认颜色
 */
- (void)setViewEdgeWithBorderWidth:(float)borderWidth cornerRadius:(float)cornerRadius borderColor:(UIColor *)borderColor;
/**
 *  给view添加边框，边框宽度，圆角，颜色都为默认
 */
- (void)setViewEdge;

/**
 *  给view切圆角
 *
 *  @param cornerRadius 圆角大小
 */
- (void)setCornerRedius:(CGFloat)cornerRadius ;
- (void)setCornerDefault ;
- (void)setCornerDefaultHalf ;

/**
 * 给view加一个边框
*/
- (void)setLayerDefalult ;
- (void)setLayerWithOfset:(CGSize)size ;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;


/**
 * Calculates the offset of this view from another view in screen coordinates.
 */
- (CGPoint)offsetFromView:(UIView*)otherView;


/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;


- (void)addSubviews:(NSArray *)views;

- (void)removeAllRecognizers;

- (void)addTapCallBack:(id)target sel:(SEL)selector;

- (void)setLeft:(CGFloat)x;

@end
