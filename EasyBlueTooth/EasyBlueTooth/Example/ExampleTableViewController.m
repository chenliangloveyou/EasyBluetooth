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
#import "EFShowView.h"
#import "EasyBlueToothManager.h"
#import "ExampleDetailViewController.h"

@interface ExampleTableViewController ()

@property (nonatomic,strong)NSArray *dataArray ;

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
    
    [[EasyBlueToothManager shareInstance] connectAllDeviceWithName:@"NFHY" timeout:10 callback:^(NSArray<EasyPeripheral *> *deviceArray, NSError *error) {
        
        if (deviceArray.count > 0) {
            ExampleDetailViewController *vc = [[ExampleDetailViewController alloc]init];
            vc.deviceArray = deviceArray ;
            [self.navigationController pushViewController:vc animated:YES];
            
            NSLog(@"%@", deviceArray);
        }
        else{
            [EFShowView showText:error.description];
        }
    }];
    
    
//    [[EasyBlueToothManager shareInstance] connectDeviceWithRule:^BOOL(EasyPeripheral *peripheral) {
//        if ([peripheral.name isEqualToString:@"EFHY"]) {
//            return YES ;
//        }
//        else{
//            return NO ;
//        }
//    } timeout:10 callback:^(EasyPeripheral *peripheral, NSError *error) {
//        if (!error) {
//            ToolDetailViewController  *vc = [[ToolDetailViewController alloc]init];
//            vc.peripheral = peripheral ;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        else{
//            [EFShowView showText:error.description];
//        }
//        NSLog(@"%@ == %@",peripheral,error);
//    }];
//    [[EasyBlueToothManager shareInstance] connectDeviceWithName:@"NFHY" timeout:10 callback:^(EasyPeripheral *peripheral, NSError *error) {
//        
//        if (!error) {
//            ToolDetailViewController  *vc = [[ToolDetailViewController alloc]init];
//            vc.peripheral = peripheral ;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        else{
//            [EFShowView showText:error.description];
//        }
//        NSLog(@"%@ == %@",peripheral,error);
//        
//    }];
    
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
                       @"连接指定规则的所有设备",
                       @"一行代码连接设备"];
    }
    return _dataArray ;
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
