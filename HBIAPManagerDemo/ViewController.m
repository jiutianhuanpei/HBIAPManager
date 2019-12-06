//
//  ViewController.m
//  HBIAPManagerDemo
//
//  Created by 沈红榜 on 2019/12/6.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import "ViewController.h"
#import "HBIAPManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    _dataArray = @[].mutableCopy;
    [self.view addSubview:self.tableView];
    
    [self fetchProductsInApple];
}

- (void)fetchProductsInApple {
    
    __weak typeof(self) weakSelf = self;
    [HBIAPManager.sharedInstance.productService fetchProducts:@[@"hejiawang07", @"hejiawang30", @"a00702e725e94d3a9691f456c5ee6027", @"92df4fafd3e04baf8c4165897c035f76"] complete:^(NSError * _Nullable error, SKProductsResponse * _Nullable response) {
        
        if (error) {
            [weakSelf.dataArray addObject:error];
        } else if (response.products == 0) {
            [weakSelf.dataArray addObject:@"商品个数为空"];
        } else {
            [weakSelf.dataArray addObjectsFromArray:response.products];
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    
    id obj = _dataArray[indexPath.row];
    if ([obj isKindOfClass:SKProduct.class]) {
        
        SKProduct *pro = (SKProduct *)obj;
        cell.textLabel.text = pro.localizedTitle;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", obj];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = _dataArray[indexPath.row];
    if (![obj isKindOfClass:SKProduct.class]) {
        return;
    }
    
    SKProduct *pro = (SKProduct *)obj;
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:true];
    [HBIAPManager.sharedInstance buyProduct:pro iapCallback:^(BOOL bIsPurchased) {
        NSLog(@"购买%@", bIsPurchased ? @"成功" : @"失败");
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:false];
    } complete:^(NSError * _Nullable error, SKPaymentTransaction * _Nullable transaction, NSDictionary * _Nullable receiptInfo) {
        
        
        if (error || transaction.error) {
            NSLog(@"校验失败：%@", error ?: transaction.error);
        } else {
            NSLog(@"校验成功，对应信息为：\n%@", receiptInfo);
            
            /*
             校验成功之后，可以在此处把收据传给自己的服务器记录，或者再次校验
             成功之后需要结束本次交易
             */
            //结束交易
            [transaction finish];
        }
    }];
    
}


#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
