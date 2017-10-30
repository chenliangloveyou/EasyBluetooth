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
#import "EFShowView.h"
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
    
//    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.centerManager stopScanDevice];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad] ;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ToolCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ToolCell class])];
    
    kWeakSelf(self)
    [self.centerManager scanDeviceWithTimeInterval:NSIntegerMax services:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }  callBack:^(EasyPeripheral *peripheral, searchFlagType searchType) {
        if (peripheral) {
            if (searchType&searchFlagTypeChanged) {
                NSInteger perpheralIndex = [weakself.dataArray indexOfObject:peripheral];
                [weakself.dataArray replaceObjectAtIndex:perpheralIndex withObject:peripheral];
            }
            else if(searchType&searchFlagTypeAdded){
                [weakself.dataArray addObject:peripheral];
            }
            else if (searchType&searchFlagTypeDisconnect || searchType&searchFlagTypeDelete){
                [weakself.dataArray removeObject:peripheral];
            }
            queueMainStart
            [weakself.tableView reloadData];
            queueEnd
        }
    }];
    
    self.centerManager.stateChangeCallback = ^(EasyCenterManager *manager, CBManagerState state) {
        [weakself managerStateChanged:state];
    };
    
}

#pragma mark - bluetooth callback

- (void)managerStateChanged:(CBManagerState)state
{
    queueMainStart
    if (state == CBManagerStatePoweredOn) {
        UIView *coverView = [[UIApplication sharedApplication].keyWindow viewWithTag:1011];
        if (coverView) {
            [coverView removeFromSuperview];
            coverView = nil ;
        }
        
        UIViewController *vc = [EasyUtils topViewController];
        if ([vc isKindOfClass:[self class]]) {
            [self.centerManager startScanDevice];
        }
        
    }
    else if (state == CBManagerStatePoweredOff){
        UILabel *coverLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        coverLabel.font = [UIFont systemFontOfSize:20];
        coverLabel.tag = 1011 ;
        coverLabel.textAlignment = NSTextAlignmentCenter ;
        coverLabel.text = @"系统蓝牙已关闭，请打开系统蓝牙";
        coverLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [[UIApplication sharedApplication].keyWindow addSubview:coverLabel];
    }
    queueEnd
}
- (void)deviceDisconnect:(EasyPeripheral *)peripheral error:(NSError *)error
{
    kWeakSelf(self)
    queueMainStart
    [EFShowView HideHud];
    [EFShowView showAlertMessageWithTitle:@"设备失去连接" contentMessage:error.localizedDescription cancelTitle:@"重新连接" cancelCallBack:^{
        //重新连接设备
        [peripheral reconnectDevice];
    } sureTitle:@"取消" sureCallBack:^{
        [weakself.navigationController popToRootViewControllerAnimated:YES];
    }];
    queueEnd
}
- (void)deviceConnect:(EasyPeripheral *)peripheral error:(NSError *)error
{
    queueMainStart
    [EFShowView HideHud];
    if (error) {
        [EFShowView showErrorText:error.domain];
    }
    else{
        ToolDetailViewController *tooD = [[ToolDetailViewController alloc]init];
        tooD.peripheral = peripheral ;
        [self.navigationController  pushViewController:tooD animated:YES];
    }
    
    queueEnd
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
        [weakself.navigationController pushViewController:tooD animated:YES];
    }
    else{
        [EFShowView showHUDMsg:@"正在连接设备..."];
        [peripheral connectDeviceWithCallback:^(EasyPeripheral *perpheral, NSError *error, deviceConnectType deviceConnectType) {
            if (deviceConnectType == deviceConnectTypeDisConnect) {
                [weakself deviceDisconnect:peripheral error:error];
            }
            else{
                [weakself deviceConnect:peripheral error:error];
            }
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
