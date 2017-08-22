//
//  ToolViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolViewController.h"
#import "ToolCell.h"

#import "EasyBlueToothManager.h"
#import "EasyUtils.h"
#import "ToolInputView.h"
#import "ToolDetailViewController.h"
@interface ToolViewController ()<UITableViewDelegate,UITableViewDelegate>

@property (nonatomic,strong)EasyCenterManager  *centerManager ;

@property (nonatomic,strong)NSMutableArray *dataArray ;

@end

@implementation ToolViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.centerManager startScanDevice];
    
    [self.tableView reloadData];
}
-(NSData *)hexString:(NSString *)hexString {
    int j=0;
    Byte bytes[20];
    ///3ds key的Byte 数组， 128位
    for(int i=0; i<[hexString length]; i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:20];
    
    return newData  ;
}
- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ToolCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ToolCell class])];
    
    kWeakSelf(self)
    self.centerManager.stateChangeCallback = ^(EasyCenterManager *manager, CBManagerState state) {
        if (state == CBManagerStatePoweredOn) {
            [weakself.centerManager startScanDevice];
        }
    };
//        NSDictionary *options  = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
     NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
    [self.centerManager scanDeviceWithTimeInterval:LONG_MAX services:@[] options:options callBack:^(EasyPeripheral *peripheral, BOOL isfinish) {
        
        NSInteger perpheralIndex = -1 ;
        for (int i = 0;  i < self.dataArray.count; i++) {
            EasyPeripheral *tempP = self.dataArray[i];
            if ([tempP.identifier isEqual:peripheral.identifier]) {
                perpheralIndex = i ;
                break ;
            }
        }
        if (perpheralIndex != -1) {
            [self.dataArray replaceObjectAtIndex:perpheralIndex withObject:peripheral];
        }
        else{
            [self.dataArray addObject:peripheral];
        }
        
        queueMainStart
        [weakself.tableView reloadData];
        queueEnd
    }];

}

#pragma mark - tableView delegate 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ToolCell cellHeight] ;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToolCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ToolCell class]) forIndexPath:indexPath];
    cell.peripheral = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.centerManager stopScanDevice];
    
    kWeakSelf(self)
    EasyPeripheral *peripheral = self.dataArray[indexPath.row];
    if (peripheral.state==CBPeripheralStateConnected) {
        ToolDetailViewController *tooD = [[ToolDetailViewController alloc]init];
        tooD.peripheral = peripheral ;
        [weakself.navigationController  pushViewController:tooD animated:YES];
    }else{
        [peripheral connectDeviceWithCallback:^(EasyPeripheral *peripheral, NSError *error) {
            queueMainStart
            ToolDetailViewController *tooD = [[ToolDetailViewController alloc]init];
            tooD.peripheral = peripheral ;
            [weakself.navigationController  pushViewController:tooD animated:YES];
            queueEnd
        }];
    }
}

#pragma mark - getter
- (NSMutableArray *)dataArray
{
    if (nil == _dataArray) {
        _dataArray  =[NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray ;
}
- (EasyCenterManager *)centerManager
{
    if (nil == _centerManager) {
        
        dispatch_queue_t queue = dispatch_queue_create("com.easyBluetootth.demo", 0);
        _centerManager = [[EasyCenterManager alloc]initWithQueue:queue options:nil];
    }
    return _centerManager ;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
