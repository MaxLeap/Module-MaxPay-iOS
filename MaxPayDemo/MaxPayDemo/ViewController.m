//
//  ViewController.m
//  MaxPayDemo
//
//  Created by 周和生 on 16/5/23.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "ViewController.h"
#import "WXApi.h"
#import "MaxPaymentManager.h"

@import MaxLeap;
@import MaxLeapPay;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) NSDictionary *demoOrder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createOrder:(id)sender {
    [self createRandomOrder];
}

- (void)createRandomOrder {
    self.demoOrder = @{
                       @"id":[[[NSUUID UUID]UUIDString].lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""],
                       @"price":@(1)
                       };
    
    self.textLabel.text = [NSString stringWithFormat:@"订单已经创建，金额： %@ （分）\n订单号：xxx%@", self.demoOrder[@"price"], [self.demoOrder[@"id"] substringFromIndex:24]];
    self.resultLabel.text = @"";
}

- (void)pay:(NSUInteger )paymentMethod {
    if (paymentMethod == 1 && ![WXApi isWXAppInstalled]) {
        NSLog(@"尚未安装微信客户端,无法支付");
        return;
    }
    
    NSString *existSchemeStr = NULL;
    NSDictionary *urlTypeDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSArray * urlTypes = urlTypeDic[@"CFBundleURLTypes"];
    if (urlTypes.count) {
        existSchemeStr = [[urlTypes firstObject][@"CFBundleURLSchemes"] firstObject];
        MLPayChannel channel = paymentMethod?(paymentMethod==1?MLPayChannelWxApp:MLPayChannelUnipayApp):MLPayChannelAliApp;
        [[MaxPaymentManager sharedManager]payWithChannel:channel
                                                 subject:@"支付"
                                                  billNo:self.demoOrder[@"id"]
                                                totalFen:[self.demoOrder[@"price"] floatValue]
                                                  scheme:existSchemeStr
                                               returnUrl:channel==MLPayChannelUnipayApp?@"http://maxleap.cn/returnUrl":nil
                                              extraAttrs:nil
                                              completion:^(BOOL succeeded, MLPayResult *result) {
                                                  NSLog(@"pay result %@", @(succeeded));
                                                  [self queryCurrentPaymentResult];
                                              }];
        
    } else {
        NSLog(@"Error: no url scheme, can not pay");
    }
}

- (void)queryCurrentPaymentResult {
    if (self.demoOrder==nil) {
        return;
    }
    
    NSString *currentOrderId = self.demoOrder[@"id"];
    [MaxLeapPay queryOrderWithBillNo:currentOrderId
                               block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                   if ([currentOrderId isEqualToString:self.demoOrder[@"id"]]) {
                                       BOOL success = NO;
                                       for (MLOrder *billInfo in objects) {
                                           if ([billInfo.billNo isEqualToString:currentOrderId] && [billInfo.status isEqualToString:@"success"]) {
                                               success = YES;
                                           }
                                       }
                                       if (success) {
                                           NSLog(@"bill %@ payed", currentOrderId);
                                           self.resultLabel.text = [NSString stringWithFormat:@"订单 xxx%@ 已支付", [self.demoOrder[@"id"] substringFromIndex:24]];
                                       } else {
                                           NSLog(@"bill %@ not payed", currentOrderId);
                                           self.resultLabel.text = [NSString stringWithFormat:@"订单 xxx%@ 未支付", [self.demoOrder[@"id"] substringFromIndex:24]];
                                       }
                                   }
                                   
                               }];

}

- (IBAction)queryOrder:(id)sender {
    [self queryCurrentPaymentResult];
}


- (IBAction)payWithAlipay:(id)sender {
    if (self.demoOrder==nil) {
        [self createRandomOrder];
    }
    [self pay:0];
}


- (IBAction)payWithWeChat:(id)sender {
    if (self.demoOrder==nil) {
        [self createRandomOrder];
    }
    [self pay:1];
}


- (IBAction)payWithUniPay:(id)sender {
    if (self.demoOrder==nil) {
        [self createRandomOrder];
    }
    [self pay:2];
}

@end
