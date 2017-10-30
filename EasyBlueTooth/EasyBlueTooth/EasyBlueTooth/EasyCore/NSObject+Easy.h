//
//  NSObject+Easy.h
//  EasyBlueTooth
//
//  Created by nf on 2017/10/30.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Easy)

- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;

@end
