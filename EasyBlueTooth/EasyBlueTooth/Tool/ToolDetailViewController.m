//
//  ToolDetailViewController.m
//  EasyBlueTooth
//
//  Created by nf on 2017/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolDetailViewController.h"
#import "ToolDetailCell.h"
#import "ToolDetailHeaderCell.h"
#import "ToolDetailHeaderView.h"

#import "EasyService.h"
#import "EasyUtils.h"
#import "EasyDescriptor.h"

#import "ToolDetailOperationViewController.h"

@interface ToolDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView ;
@property (nonatomic,strong)NSArray *advertisementArray ;

@property (nonatomic,assign)BOOL isShowfirstSection ;//第一行是否打开
@end

@implementation ToolDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.advertisementArray = [self.peripheral.advertisementData allKeys];

    [self.view addSubview:self.tableView];
    
    kWeakSelf(self)
    [self.peripheral discoverAllDeviceServiceWithCallback:^(EasyPeripheral *peripheral, NSArray<EasyService *> *serviceArray, NSError *error) {
        
        for (EasyService *tempS in serviceArray) {
//            NSLog(@" %@  = %@",tempS.UUID ,tempS.description);
            
            [tempS discoverCharacteristicWithCallback:^(NSArray<EasyCharacteristic *> *characteristics, NSError *error) {
//                NSLog(@" %@  = %@",characteristics , error );
                
                for (EasyCharacteristic *tempC in characteristics) {
                    [tempC discoverDescriptorWithCallback:^(NSArray<EasyDescriptor *> *descriptorArray, NSError *error) {
//                        NSLog(@"%@ ====", descriptorArray)  ;
                        if (descriptorArray.count > 0) {
                            for (EasyDescriptor *d in descriptorArray) {
//                                NSLog(@"%@ - %@ %@ ", d,d.UUID ,d.value);
                            }
                        }
                        for (EasyDescriptor *desc in descriptorArray) {
                            [desc readValueWithCallback:^(EasyDescriptor *descriptor, NSError *error) {
//                                NSLog(@"%@ ,%@ ",descriptor.value,error);
                            }];
                        }
//                        NSLog(@"%@ ==== ",error);
                        queueMainStart
                        [weakself.tableView reloadData ];
                        queueEnd
                    }];
                }
            }];
        }
//        NSLog(@"%@  == %@",serviceArray,error);
    }];
    
}

#pragma mark - tableView delegate 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.peripheral.serviceArray.count + 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section) {
        EasyService *tempService = self.peripheral.serviceArray[section-1];
        return tempService.characteristicArray.count ;
    }
    
    if (_isShowfirstSection) {
        return self.peripheral.advertisementData.count ;
    }
    return 0 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ToolDetailCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToolDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ToolDetailCell class]) forIndexPath:indexPath];
    cell.accessoryType = indexPath.section ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone ;
    if (indexPath.section) {
        EasyService *tempS = self.peripheral.serviceArray[indexPath.section-1] ;
        EasyCharacteristic *tempC = tempS.characteristicArray[indexPath.row];
        cell.character = tempC ;
    }
    else{
        cell.titleString = self.advertisementArray[indexPath.row];
        cell.subTitleString = self.peripheral.advertisementData[self.advertisementArray[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section) {
        
        EasyService *tempS = self.peripheral.serviceArray[indexPath.section-1] ;
        EasyCharacteristic *tempC = tempS.characteristicArray[indexPath.row];
        
        ToolDetailOperationViewController *option = [[ToolDetailOperationViewController alloc]init];
        option.characteristic = tempC ;
        [self.navigationController pushViewController:option animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [ToolDetailHeaderCell cellHeight] ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ToolDetailHeaderCell *headerView = (ToolDetailHeaderCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ToolDetailHeaderCell class])];
    NSString *serviceName = @"advertisement data" ;
    if (section) {
        EasyService *tempS = self.peripheral.serviceArray[section-1];
        serviceName = tempS.name ;
    }
    headerView.serviceName = serviceName ;
    headerView.sectionState = section==0 ? self.isShowfirstSection : -1 ;
    kWeakSelf(self)
    headerView.callback = ^(BOOL isHidden){
        _isShowfirstSection = isHidden ;
        [weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    };
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
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ToolDetailCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ToolDetailCell class])];
        [_tableView registerClass:[ToolDetailHeaderCell class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ToolDetailHeaderCell class])];

        _tableView.tableHeaderView = [ToolDetailHeaderView headerViewWithPeripheral:self.peripheral]; ;
    }
    return _tableView ;
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
