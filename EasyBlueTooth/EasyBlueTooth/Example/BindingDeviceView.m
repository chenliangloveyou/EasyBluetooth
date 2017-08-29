//
//  BindingDeviceView.m
//  EFHealth
//
//  Created by nf on 16/3/18.
//  Copyright © 2016年 ef. All rights reserved.
//

#import "BindingDeviceView.h"

#import "EasyUtils.h"
#import "EasyPeripheral.h"

@interface BindingDeviceView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak)id<BindingDeviceViewProtocol>Delegate ;
@property (nonatomic,strong)NSArray *dataArray ;

@property (nonatomic,assign)long selectIndex ;
@end

@implementation BindingDeviceView

- (void)dealloc
{

}
+(instancetype)BindingDeviceViewDelegate:(id<BindingDeviceViewProtocol>)Delegate dataArray:(NSArray *)dataArray
{
    BindingDeviceView *view = [[BindingDeviceView alloc]init];
    view.Delegate = Delegate ;
    view.dataArray = dataArray ;
    
    return view ;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self createUI];
    }
    return self ;
}

- (void)createUI
{
    
    UIView *coverLabel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    coverLabel.tag = 10101 ;
    coverLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [[UIApplication sharedApplication].keyWindow addSubview:coverLabel];
    
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-280)/2, (SCREEN_HEIGHT-300)/2, 280, 300)];
    bgView.backgroundColor = [UIColor whiteColor] ;
    [bgView setCornerRedius:10];
    [coverLabel  addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,300 , 49 )];
    titleLabel.textAlignment = NSTextAlignmentCenter ;
    titleLabel.text = @"选择一个需要绑定的设备";
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    titleLabel.tag = 1091 ;
//    titleLabel.textColor = kColorDefult ;
    [bgView addSubview:titleLabel];
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 49, bgView.width, 1)];
    line.backgroundColor = [UIColor blueColor];
    [bgView addSubview:line];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, bgView.width, bgView.height-100) style:UITableViewStylePlain];
    tableView.dataSource = self ;
    tableView.delegate = self ;
    [bgView addSubview:tableView];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, bgView.height-50, bgView.width, 1)];
    line1.backgroundColor = [UIColor blueColor];
    [bgView addSubview:line1];
    
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, bgView.height-49, bgView.width/2-0.5, 49)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBntClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setCornerDefault];
    [bgView addSubview:cancelBtn];
    
    UIView *seperatLine = [[UIView alloc]initWithFrame:CGRectMake(cancelBtn.right, cancelBtn.top, 1.0, cancelBtn.height)];
    seperatLine.backgroundColor = [UIColor blueColor];
    [bgView addSubview:seperatLine];
    
    UIButton *sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(bgView.width/2+0.5, bgView.height-50, bgView.width/2, 49)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [sureBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setCornerDefault];
    [bgView addSubview:sureBtn];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID=  @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.textAlignment = NSTextAlignmentCenter ;
    }
   
    EasyPeripheral *tempP = _dataArray[indexPath.row];
   
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", tempP.name,tempP.identifier.UUIDString];
    
    if (indexPath.row == self.selectIndex) {
         cell.textLabel.textColor = [UIColor blueColor] ;
    }
    else{
         cell.textLabel.textColor = [UIColor lightGrayColor] ;
    }
    
    return cell ;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectIndex = indexPath.row ;
    [tableView reloadData];
}

- (void)sureBtnClick
{
    
    if (self.Delegate) {
        EasyPeripheral *tempP = _dataArray[self.selectIndex];

        [self.Delegate BindingDeviceViewSure:self device:tempP.identifier.UUIDString];
    }
    UIView *vi = [[UIApplication sharedApplication].keyWindow viewWithTag:10101];
    if (vi)   [vi removeFromSuperview];
    [self removeFromSuperview];
}
- (void)cancelBntClick
{
    if (self.Delegate) {
        [self.Delegate BindingDeviceViewCancel:self];
    }
    
    UIView *vi = [[UIApplication sharedApplication].keyWindow viewWithTag:10101];
    if (vi)   [vi removeFromSuperview];
    [self removeFromSuperview];
}

@end





