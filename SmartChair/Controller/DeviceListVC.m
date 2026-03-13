//
//  DeviceListVC.m
//  SmartChair
//
//  Created by 张志恒 on 2026/1/4.
//

#import "DeviceListVC.h"
#import "HomeViewController.h"
#import "MyBluetoothManager.h"
#import <Masonry/Masonry.h>

@interface DeviceListVC () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate>

@property(nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *devices;
//@property (nonatomic, strong) CBCentralManager *central;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation DeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackgroundView];
    [self setupTableView];
    
    self.devices = @[].mutableCopy;
    
    [[MyBluetoothManager sharedInstance] startScan];
    [[MyBluetoothManager sharedInstance] setOnDiscoverPeripheral:^(CBPeripheral * _Nonnull peripheral, NSDictionary * _Nonnull advertisementData, NSNumber * _Nonnull RSSI) {
        // 去重
        for (CBPeripheral *p in self.devices) {
            if ([p.identifier isEqual:peripheral.identifier]) {
                return;
            }
        }

        [self.devices addObject:peripheral];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [[MyBluetoothManager sharedInstance] setOnConnectSuccess:^(CBPeripheral * _Nonnull peripheral) {
    
        if ([self.delegate respondsToSelector:@selector(connectSuccess:)]) {
            [self.delegate connectSuccess:peripheral.identifier.UUIDString];
        }
        [self.indicatorView stopAnimating];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)setupBackgroundView
{
//    self.title = @"扫描到设备";
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    CGRect frame = self.view.bounds;
    frame.origin.x = 200;
    frame.size.width -= 400;
    frame.origin.y = 50;
    frame.size.height -= 100;
    self.contentView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    self.contentView.layer.cornerRadius = 20;
    self.contentView.layer.masksToBounds = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:button];
//    button.titleLabel.font = kFont(kSize_S2, kWeight_W2);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(100, 50));
    }];
}

- (void)buttonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTableView {
    
    self.tableView = [[UITableView alloc]
                      initWithFrame:CGRectZero
                      style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.contentView addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = nil;
    self.tableView.sectionHeaderTopPadding = 0;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(60);
        make.left.bottom.right.equalTo(self.contentView);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:@"cell"];
    }

    CBPeripheral *p = self.devices[indexPath.row];
    cell.textLabel.text = p.name;
    cell.detailTextLabel.text = p.identifier.UUIDString;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    CBPeripheral *peripheral = self.devices[indexPath.row];

    [[MyBluetoothManager sharedInstance] stopScan];
    // 这里开始连接
    [[MyBluetoothManager sharedInstance] connectDeviceWith:peripheral];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    [self.view addSubview:self.indicatorView];
    self.indicatorView.frame = self.view.bounds;
    [self.indicatorView startAnimating];
}

#pragma mark - DeviceListVCDelegate
//- (void)deviceListVC:(DeviceListVC *)vc
//     didSelectDevice:(CBPeripheral *)peripheral {
//
//    NSLog(@"选择设备：%@", peripheral.name);
//
//    // 这里开始连接
//    [self.central connectPeripheral:peripheral options:nil];
//}

#pragma mark - BLE
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//    if (central.state == CBManagerStatePoweredOn) {
//        [self.devices removeAllObjects];
//        [self.central scanForPeripheralsWithServices:nil options:nil];
//    }
//}

//- (void)centralManager:(CBCentralManager *)central
// didDiscoverPeripheral:(CBPeripheral *)peripheral
//     advertisementData:(NSDictionary *)advertisementData
//                  RSSI:(NSNumber *)RSSI {
//
//    if (![peripheral.name isEqualToString:@"JE_BT"]) return;
//
//    
//}

//- (void)centralManager:(CBCentralManager *)central
//  didConnectPeripheral:(CBPeripheral *)peripheral {
//
//    NSLog(@"蓝牙连接成功：%@", peripheral.name);
//
//    NSString *uuid = peripheral.identifier.UUIDString;
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//    if ([self.delegate respondsToSelector:@selector(connectSuccess:)]) {
//        [self.delegate connectSuccess:uuid];
//    }
////    dispatch_async(dispatch_get_main_queue(), ^{
////        [self switchToHomeVC];
////    });
//}


@end
