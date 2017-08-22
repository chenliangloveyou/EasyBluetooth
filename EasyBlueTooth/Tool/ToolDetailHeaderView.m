//
//  ToolDetailHeaderView.m
//  EasyBlueTooth
//
//  Created by Mr_Chen on 17/8/18.
//  Copyright © 2017年 chenSir. All rights reserved.
//

#import "ToolDetailHeaderView.h"
#import "EasyUtils.h"
#import "AppDelegate.h"
@interface ToolDetailHeaderView()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (nonatomic,strong)EasyPeripheral *peripheral ;
@end

@implementation ToolDetailHeaderView

+ (instancetype)headerViewWithPeripheral:(EasyPeripheral *)peripheral
{
    ToolDetailHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ToolDetailHeaderView class]) owner:nil options:nil]firstObject] ;
    view.nameLabel.text = peripheral.name ;
    view.uuidLabel.text = [NSString stringWithFormat:@"UUID:%@",peripheral.identifier] ;
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            view.stateLabel.text = @"已连接";
            break;
        case CBPeripheralStateDisconnected:
            view.stateLabel.text = @"已断开连接";
            break ;
        default:
            break;
    }

    view.peripheral = peripheral ;
    return view ;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)dealloc
{
    [self.peripheral.peripheral removeObserver:self forKeyPath:@"state"];
}

- (void)setPeripheral:(EasyPeripheral *)peripheral
{
    _peripheral = peripheral ;
    [self.peripheral.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CBPeripheral *periheral = (CBPeripheral *)object ;
    NSLog(@"\n\n ,,, %ld",(long)periheral.state );
    if (periheral.state == CBPeripheralStateDisconnected) {
        self.stateLabel.textColor = [UIColor redColor];
        self.stateLabel.text = @"设备已失去连接...";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备已失去连接..." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            dispatch_after(0.2, dispatch_get_main_queue(), ^{
//                [alertController dismissViewControllerAnimated:YES completion:nil];
//            });
        }];
        [alertController addAction:action];
        UIViewController *cv = [EasyUtils topViewController];
        if (![cv isKindOfClass:[UIAlertController class]]) {
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
#warning 待处理
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Remind" message:@"设备已失去连接..." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alertView show];
    }
    
    
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
