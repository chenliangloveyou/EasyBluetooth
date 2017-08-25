//
//  EasyManagerOptions.h
//  EasyBlueTooth
//
//  Created by nf on 2017/8/25.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EasyManagerOptions : NSObject

/**
 * 蓝牙所有操作所在的线程。如果不传，将会在主线程上操作。
 * note：最好创建一个线程传入。因为返回数据后的操作已经都放到了主线程上。
 */
@property (nonatomic,strong)dispatch_queue_t managerQueue ;

/**
 * 创建manager的参数
 * 
 */
@property (nonatomic,strong)NSDictionary *managerDictionary ;//manager初始化所带的参数

@property (nonatomic,strong)NSArray *scanOptions ;  //扫描时所带的条件

@property (nonatomic,strong)NSArray *serviceArray ;//连接设备所需的服务.

@property (nonatomic,strong)NSArray *connectOptions ;//连接设备时所带的条件



@end
