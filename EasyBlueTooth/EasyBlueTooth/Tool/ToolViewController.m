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
    
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
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
        [SVProgressHUD showInfoWithStatus:@"正在连接设备..."];
        [peripheral connectDeviceWithDisconnectCallback:^(EasyPeripheral *peripheral, NSError *error) {
            queueMainStart
            [SVProgressHUD dismiss];
            [EFShowView showAlertMessageWithTitle:@"设备失去连接" contentMessage:error.localizedDescription cancelTitle:@"重新连接" cancelCallBack:^{
                //重新连接设备
                [peripheral reconnectDevice];
            } sureTitle:@"取消" sureCallBack:^{
                [weakself.navigationController popToRootViewControllerAnimated:YES];
            }];
            queueEnd
        } Callback:^(EasyPeripheral *perpheral, NSError *error) {
            queueMainStart
            [SVProgressHUD dismiss];
            if (error) {
                [EFShowView showErrorText:error.domain];
            }
            else{
                ToolDetailViewController *tooD = [[ToolDetailViewController alloc]init];
                tooD.peripheral = peripheral ;
                [weakself.navigationController  pushViewController:tooD animated:YES];
            }
            
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
