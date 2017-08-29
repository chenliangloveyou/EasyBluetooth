//
//  ExampleTableViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ExampleTableViewController.h"
#import "ExampleCell.h"

#import "EasyUtils.h"   
#import "EasyBlueToothManager.h"

#import "ExampleScanRuleViewController.h"
#import "ExampleScanNameViewController.h"
#import "ExampleOneLineCodeViewController.h"
#import "ExampleSavedViewController.h"
#import "ExampleAllRuleDeviceViewController.h"

@interface ExampleTableViewController ()

@property (nonatomic,strong)NSArray *dataArray ;

@property (nonatomic,strong)EasyBlueToothManager *bleManager ;

@end

@implementation ExampleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ExampleCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ExampleCell class])];
    self.tableView.tableHeaderView = [self tableHeaderView];
    
}


#pragma mark - Tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ExampleCell cellHieght] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    ExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ExampleCell class]) forIndexPath:indexPath];
    cell.titleString = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self tableViewDidSelectIndex:indexPath.row];
}


#pragma mark - ble manager
- (void)tableViewDidSelectIndex:(long)index
{
    UIViewController *vc =nil ;
    switch (index) {
        case 0:vc = [[ExampleScanNameViewController alloc]init]; break;
        case 1:vc = [[ExampleScanRuleViewController alloc]init];  break;
        case 2:vc = [[ExampleSavedViewController alloc]init];break ;
        case 3:vc = [[ExampleOneLineCodeViewController alloc]init];break ;
        default:vc= [[ExampleAllRuleDeviceViewController alloc]init]; break;
    }
    
    ((ExampleSavedViewController *)vc).bleManager = self.bleManager ;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - getter

- (UIView *)tableHeaderView
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , 100)];
    label.text = @"请选择一种连接方式";
    label.textAlignment = NSTextAlignmentCenter ;
    label.font = [UIFont boldSystemFontOfSize:20];
    return label ;
}

- (NSArray *)dataArray
{
    if (nil == _dataArray) {
        _dataArray = @[@"指定名称连接设备",
                       @"指定规则连接设备",
                       @"扫描指定保存到本地的设备",
                       @"一行代码连接设备",
                       @"扫描指定名称所有设别",
                       @"连接指定规则的所有设备",];
    }
    return _dataArray ;
}

- (EasyBlueToothManager *)bleManager
{
    if (nil == _bleManager) {
        _bleManager = [EasyBlueToothManager shareInstance];
        
        dispatch_queue_t queue = dispatch_queue_create("com.easyBluetooth.queue", 0);
        NSDictionary *managerDict = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
        NSDictionary *scanDict = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
        NSDictionary *connectDict = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
        
        EasyManagerOptions *options = [[EasyManagerOptions alloc]initWithManagerQueue:queue managerDictionary:managerDict scanOptions:scanDict scanServiceArray:nil connectOptions:connectDict];
        options.scanTimeOut = 6 ;
        options.connectTimeOut = 5 ;
        options.autoConnectAfterDisconnect = YES ;
        
        [EasyBlueToothManager shareInstance].managerOptions = options ;
        
    }
    
    return _bleManager ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
