//
//  ToolDetailOperationViewController.m
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/19.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolDetailOperationViewController.h"
#import "ToolDetailHeaderCell.h"
#import "ToolDetailOperationCell.h"

#import "EasyDescriptor.h"
#import "EasyUtils.h"
#import "ToolInputView.h"

@interface ToolDetailOperationViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView ;
@property (nonatomic,strong)NSMutableArray *dataArray ;

@property (nonatomic,strong)ToolInputView *inputView ;
@end

@implementation ToolDetailOperationViewController

- (void)dealloc
{
    [self.characteristic removeObserver:self forKeyPath:@"notifyDataArray"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    NSArray *array  = [self.characteristic.propertiesString componentsSeparatedByString:@" "];
    self.dataArray = [NSMutableArray arrayWithArray:array];
    
    [self.tableView reloadData];
    
    [self.characteristic addObserver:self forKeyPath:@"notifyDataArray" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"notifyDataArray"]) {
        kWeakSelf(self)
        queueMainStart
        [weakself.tableView reloadData];
        queueEnd
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count + 2 ;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.dataArray.count ) {
        NSString *tempString = self.dataArray[section];
        if ([tempString isEqualToString:@"Write"]||[tempString isEqualToString:@"WriteWithoutResponse"]) {
            return self.characteristic.writeDataArray.count + 1 ;
        }
        else if ([tempString isEqualToString:@"Read"]){
            return self.characteristic.readDataArray.count + 1;
        }
        else if ([tempString isEqualToString:@"Notify"]||[tempString isEqualToString:@"Indicate"]){
            return self.characteristic.notifyDataArray.count + 1 ;
        }
        else{
            return 0 ;
        }
    }
    else if(section == self.dataArray.count){
        return self.characteristic.descriptorArray.count ;
    }
    else{
        return self.dataArray.count ;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ToolDetailOperationCell cellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToolDetailOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ToolDetailOperationCell class]) forIndexPath:indexPath];
  
    cell.isOperation  = (indexPath.section<self.dataArray.count)&&(!indexPath.row);
 
    if (indexPath.section < self.dataArray.count ) {
        
        NSString *tempString = self.dataArray[indexPath.section];
        if (indexPath.row == 0) {
            cell.title = [NSString stringWithFormat:@"%@ a new value",tempString] ;
            if ([tempString isEqualToString:@"Notify"]) {
                cell.title = [NSString stringWithFormat:@"%@",self.characteristic.isNotifying?@"Stop notification ":@"Tap to start notification"];
            }
        }else{
            if ([tempString isEqualToString:@"Write"] ||[tempString isEqualToString:@"WriteWithoutResponse"]) {
                cell.title = self.characteristic.writeDataArray[indexPath.row-1] ;
            }
            else if ([tempString isEqualToString:@"Read"]){
                cell.title = self.characteristic.readDataArray[indexPath.row-1] ;
            }
            else if ([tempString isEqualToString:@"Notify"]||[tempString isEqualToString:@"Indicate"]){
                cell.title = self.characteristic.notifyDataArray[indexPath.row-1] ;
            }
            
        }
        
    }
    else if (indexPath.section == self.dataArray.count){
        EasyDescriptor *tempD = self.characteristic.descriptorArray[indexPath.row];
        cell.title = [NSString stringWithFormat:@"%@",tempD.UUID];
    }
    else{
        cell.title = self.dataArray[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section < self.dataArray.count && !indexPath.row) {
        NSString *tempString = self.dataArray[indexPath.section];
        
        if ([tempString isEqualToString:@"Write"]||[tempString isEqualToString:@"WriteWithoutResponse"]) {
            _inputView =[ToolInputView toolInputViewWithCallback:^(NSString *number) {
                _inputView = nil;
                
                if (number.length == 0) {
                    return  ;
                }
                NSData *data = [EasyUtils convertHexStrToData:number];
                
                //fe6a
                NSLog(@" ---- %@ ",data);
                [self.characteristic writeValueWithData:data callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                    kWeakSelf(self)
                    queueMainStart
                    [weakself.tableView reloadData];
                    queueEnd
                }];
                
            }];
        }
        else if ([tempString isEqualToString:@"Read"]){
            [self.characteristic readValueWithCallback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
            }];
        }
        else if ([tempString isEqualToString:@"Notify"]||[tempString isEqualToString:@"Indicate"]){
            [self.characteristic notifyWithValue:!self.characteristic.isNotifying callback:^(EasyCharacteristic *characteristic, NSData *data, NSError *error) {
                kWeakSelf(self)
                queueMainStart
                [weakself.tableView reloadData];
                queueEnd
            }];
            
        }
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ToolDetailHeaderCell cellHeight] ;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ToolDetailHeaderCell *headerView = (ToolDetailHeaderCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ToolDetailHeaderCell class])];
    if (section < self.dataArray.count ) {
        headerView.serviceName = self.dataArray[section];
    }
    else if (section == self.dataArray.count){
        headerView.serviceName = @"descriptors";
    }else{
        headerView.serviceName = @"properties";
    }
    return headerView ;
}

#pragma mark - getter
- (UITableView *)tableView
{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self ;
        _tableView.dataSource = self ;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ToolDetailOperationCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ToolDetailOperationCell class])];
        [_tableView registerClass:[ToolDetailHeaderCell class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ToolDetailHeaderCell class])];
    }
    return _tableView ;
}
- (NSMutableArray *)dataArray
{
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray ;
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
