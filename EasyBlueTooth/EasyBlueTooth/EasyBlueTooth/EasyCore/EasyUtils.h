//
//  EasyUtils.h
//  EasyBlueTooth
//
//  Created by nf on 2016/8/14.
//  Copyright © 2016年 chenSir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//强弱引用
#define kWeakSelf(type)__weak typeof(type)weak##type = type;
#define kStrongSelf(type)__strong typeof(type)type = weak##type;


/***线程****/
#define queueGlobalStart dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

#define queueMainStart dispatch_async(dispatch_get_main_queue(), ^{

#define QueueStartAfterTime(time) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){

#define queueEnd  });

/**打印****/
#define ISSHOWLOG 1

//接受系统消息
#define ISSHOWRECEIVELOG 1

//调用API
#define ISSHOWSENDLOG 1

#define EasyLog(fmt, ...) if(ISSHOWLOG) { NSLog(fmt,##__VA_ARGS__); }

#define EasyLog_R(fmt, ...) if(ISSHOWRECEIVELOG&&ISSHOWLOG) { NSLog(fmt,##__VA_ARGS__); }

#define EasyLog_S(fmt, ...) if(ISSHOWSENDLOG&&ISSHOWLOG) { NSLog(fmt,##__VA_ARGS__); }

// 是否为空
#define ISEMPTY(_v) (_v == nil || _v.length == 0)



/********存储数据*********/
#define EFUserDefaults [NSUserDefaults standardUserDefaults]

#define EFUserDefaultsSetObj(obj, key) \
[EFUserDefaults setObject:obj forKey:key]; \
[EFUserDefaults synchronize];

#define EFUserDefaultsObjForKey(key) [EFUserDefaults objectForKey:key]


//屏幕宽度
#define  SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
//屏幕高度
#define  SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height


@interface EasyUtils : NSObject


 //将16进制的字符串转换成NSData
+ (NSMutableData *)convertHexStrToData:(NSString *)str ;

//十六进制转换为普通字符串的。
+ (NSString *)ConvertHexStringToString:(NSString *)hexString;
//普通字符串转换为十六进制
+ (NSString *)ConvertStringToHexString:(NSString *)string;
//int转data
+(NSData *)ConvertIntToData:(int)i;
//data转int
+(int)ConvertDataToInt:(NSData *)data;
//十六进制转换为普通字符串的。
+ (NSData *)ConvertHexStringToData:(NSString *)hexString;

//最上方的控制器
+ (UIViewController *)topViewController ;

@end
