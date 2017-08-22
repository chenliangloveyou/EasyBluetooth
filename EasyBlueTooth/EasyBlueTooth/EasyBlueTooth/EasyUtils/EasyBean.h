//
//  EasyBean.h
//  EasyBlueTooth
//
//  Created by nf on 2017/8/14.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EasyBean : NSObject

/**
 * 需要连接的蓝牙名称
 */
@property (nonatomic,strong)NSString *blueToothName ;

/**
 * 需要连接的服务uuid
 */
@property (nonatomic,strong)NSString *serviceUUID ;

/**
 * 需要数据交互的uuid
 */
@property (nonatomic,strong)NSString *characteristicUUID ;


@end
