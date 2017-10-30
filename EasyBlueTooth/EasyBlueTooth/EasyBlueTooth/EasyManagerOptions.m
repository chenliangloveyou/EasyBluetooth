//
//  EasyManagerOptions.m
//  EasyBlueTooth
//
//  Created by nf on 2016/8/25.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import "EasyManagerOptions.h"

@implementation EasyManagerOptions

- (instancetype)init
{
    if (self = [super init]) {
        _scanTimeOut = NSIntegerMax ;
        _connectTimeOut = 5 ;
    }
    return self ;
}
- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue managerDictionary:(NSDictionary *)managerDictionary
{
    return [self initWithManagerQueue:queue managerDictionary:managerDictionary scanOptions:nil scanServiceArray:nil];
}

- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue managerDictionary:(NSDictionary *)managerDictionary scanOptions:(NSDictionary *)scanOptions scanServiceArray:(NSArray *)scanServiceArray
{
    return [self initWithManagerQueue:queue managerDictionary:managerDictionary scanOptions:scanOptions scanServiceArray:scanServiceArray connectOptions:nil];
}

- (instancetype)initWithManagerQueue:(dispatch_queue_t)queue managerDictionary:(NSDictionary *)managerDictionary scanOptions:(NSDictionary *)scanOptions scanServiceArray:(NSArray *)scanServiceArray connectOptions:(NSDictionary *)connectOptions
{
    if (self = [self init]) {
        _managerQueue = queue ;
        _managerDictionary = managerDictionary ;
        _scanOptions = scanOptions ;
        _scanServiceArray = scanServiceArray ;
        _connectOptions = connectOptions ;
    }
    return self ;
}

@end
