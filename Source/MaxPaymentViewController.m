//
//  MaxPaymentViewController.m
//  MaxPayDemo
//
//  Created by 周和生 on 16/5/25.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MaxPaymentViewController.h"
#import "MaxPaymentManager.h"

#define ImageNamed(x)               [UIImage imageNamed:x]



@implementation MaxPaymentOrder
@end


@interface PayButtonView : UIView

@property (nonatomic, strong) UIButton *payButton;

@end

@implementation PayButtonView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.payButton.bounds = CGRectMake(0, 0, self.frame.size.width-80, 44);
    self.payButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

@end



@interface MaxPaymentViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, assign) NSInteger paymentMethod;

@end


@implementation MaxPaymentViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"付款方式";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.paymentMethod = 0;

    [self configureTableView];
    
    PayButtonView *buttonView = [[PayButtonView alloc]initWithFrame:CGRectMake(0, 0, 200, 70)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor colorWithRed:0.98 green:0.46 blue:0.16 alpha:1.00];
    [btn setTitle:@"确认支付" forState:UIControlStateNormal];
    btn.layer.cornerRadius = 2;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:btn];
    buttonView.payButton = btn;
    self.tableView.tableFooterView = buttonView;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}


#pragma mark- Override Parent Methods
- (void)dealloc {

}

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.contentMode = UIViewContentModeTopLeft|UIViewContentModeBottomRight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 129;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PriceCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MethodCell"];

    
    [self.view addSubview:self.tableView];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 20;
    }
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier1 = @"PriceCell";
    static NSString *CellIdentifier2 = @"MethodCell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        UILabel *label = cell.textLabel;
        NSDecimalNumber *price = [self.order.totalPrice decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        label.text = [NSString stringWithFormat:@"支付金额:￥%@", price];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return cell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        
        UIImageView *imgView = cell.imageView;
        UILabel *label = cell.textLabel;
        UIImageView *checkImageView = [[UIImageView alloc]initWithImage:ImageNamed(@"ic_pay_normal")];
        checkImageView.frame = CGRectMake(0, 0, 20, 20);
        cell.accessoryView = checkImageView;
        
        if (indexPath.row == 0) {
            imgView.image = ImageNamed(@"ic_pay_with_alipay");
            label.text = @"支付宝";
            if (self.paymentMethod == 0) {
                checkImageView.image = [ImageNamed(@"ic_pay_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        
        if (indexPath.row == 1) {
            imgView.image = ImageNamed(@"ic_pay_with_wechat");
            label.text = @"微信支付";
            if (self.paymentMethod == 1) {
                checkImageView.image = [ImageNamed(@"ic_pay_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        
        if (indexPath.row == 2) {
            imgView.image = ImageNamed(@"ic_pay_with_unionpay");
            label.text = @"银联支付";
            if (self.paymentMethod == 2) {
                checkImageView.image = [ImageNamed(@"ic_pay_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    if (section == 1) {
        return 3;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        
        self.paymentMethod = indexPath.row;
        [self.tableView reloadData];
    }
}

#pragma mark- Actions
- (void)confirmButtonPressed:(id)sender {
    
    
    NSString *existSchemeStr = NULL;
    NSDictionary *urlTypeDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSArray * urlTypes = urlTypeDic[@"CFBundleURLTypes"];
    if (urlTypes.count) {
        existSchemeStr = [[urlTypes firstObject][@"CFBundleURLSchemes"] firstObject];
        MLPayChannel channel = self.paymentMethod?(self.paymentMethod==1?MLPayChannelWxApp:MLPayChannelUnipayApp):MLPayChannelAliApp;
        [[MaxPaymentManager sharedManager]payWithChannel:channel
                                                 subject:@"支付"
                                                  billNo:self.order.orderId
                                                totalFen:self.order.totalPrice.floatValue
                                                  scheme:existSchemeStr
                                               returnUrl:channel==MLPayChannelUnipayApp?self.unipayReturnUrl:nil
                                              extraAttrs:self.order.extraInfo
                                              completion:^(BOOL succeeded, MLPayResult *result) {

                                                  if (self.completionBlock) {
                                                      self.completionBlock(succeeded, result);
                                                  }
                                              }];
        
    } else {
        NSLog(@"Error: no url scheme, can not pay");
    }
    
}




@end


