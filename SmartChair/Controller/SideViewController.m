//
//  SideViewController.m
//  SmartChair
//
//  Created by 张志恒 on 2025/12/25.
//

#import "SideViewController.h"
#import <Masonry/Masonry.h>
#import "MyBluetoothManager.h"

@interface SideViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation SideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self buildTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMototList:) name:@"update_motor_list" object:nil];
}

- (void)buildTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.rowHeight = 50;
    tableView.sectionHeaderHeight = 0.01;
    tableView.sectionFooterHeight = 0.01;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(150);
//        make.top.bottom.right.equalTo(self.view);
        make.edges.equalTo(self.view);
    }];
    self.tableView = tableView;
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MyBluetoothManager sharedInstance].allMotorArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
        cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    }
    MotorModel *model = [MyBluetoothManager sharedInstance].allMotorArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [MotorModel nameDescription:model.motorID]];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"p=%ld%% \ns:%@",model.progress,[MotorModel statusDescription:model.status]];
    
    return cell;
}

#pragma mark - tableView delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)updateMototList:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
