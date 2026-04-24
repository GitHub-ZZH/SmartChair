//
//  DeviceSettingViewController.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import "DeviceSettingViewController.h"
#import <Masonry/Masonry.h>
#import "DeviceSettingCell.h"
#import "MyBluetoothManager.h"
#import "BluetoothMessage.h"
#import "ViewController.h"
#import "LanguageManager.h"
#import "GlobalToast.h"

@interface DeviceSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *arrList;
@property(nonatomic, strong) UITableView *tableView;


@end

@implementation DeviceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    NSArray *tempArr = @[@(1), @(2), @(3), @(4), @(5)];
    self.arrList = [NSMutableArray array];
    for (int i = 0; i < tempArr.count; i++) {
        MotorModel *model = [[MotorModel alloc] init];
        model.motorID = [tempArr[i] intValue];
        [self.arrList addObject:model];
    }
    
    [self buildNavItem];
    [self buildTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMototList:) name:@"update_motor_list" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)buildNavItem
{
    UIBarButtonItem *itemStudy = [[UIBarButtonItem alloc] initWithTitle:@"一键自学习" style:UIBarButtonItemStyleDone target:self action:@selector(buttonStudyAction)];
    
    self.navigationItem.rightBarButtonItem = itemStudy;
    
    self.title = @"后台设置";
}

- (void)buildTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.rowHeight = 60;
    tableView.sectionHeaderHeight = 0.01;
    tableView.sectionFooterHeight = 0.01;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.bottom.right.equalTo(self.view);
    }];
    self.tableView = tableView;
}

#pragma mark - tableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.arrList.count;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceSettingCell"];
        if (!cell) {
            cell = [[DeviceSettingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DeviceSettingCell"];
        }
//        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chair_selected"]];
        
        MotorModel *model = self.arrList[indexPath.row];
        for (MotorModel *temp in [MyBluetoothManager sharedInstance].allMotorArr) {
            if (model.motorID == temp.motorID) {
                model.status = temp.status;
            }
        }
        cell.model = model;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        }
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
        if (indexPath.row == 0) {
            cell.textLabel.text = @"参数设置";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"重新配对";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"修改密码";
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"中英文切换";
            cell.detailTextLabel.text = @"中文";
            if ([[[LanguageManager shared] getLanguage] isEqualToString:@"en"]) {
                cell.detailTextLabel.text = @"英文";
            }
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"零重力自动运行";
            
            BOOL isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"zeroAutoPlay"];
            
            UISwitch *switchButton = [[UISwitch alloc] init];
            switchButton.on = isOpen;
            [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchButton;
        }
        
        return cell;
    }
}

#pragma mark - tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"TableHeaderView"];
        
        UIView *lineView = [[UIView alloc] init];
        [headerView addSubview:lineView];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(headerView);
            make.height.mas_equalTo(0.5);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        [headerView addSubview:label];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"自学习电机列表";
        if (section == 1) {
            label.text = @"其他功能";
        }
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView).offset(16);
            make.left.equalTo(headerView).offset(20);
            make.bottom.right.equalTo(headerView);
        }];
        
        return headerView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self parameterSetting];
        } else if (indexPath.row == 1) {
            [self deleteDevice];
        } else if (indexPath.row == 2) {
            [self changePassword];
        } else if (indexPath.row == 3) {
            if ([[[LanguageManager shared] getLanguage] isEqualToString:@"en"]) {
                [[LanguageManager shared] setLanguage:@"zh-Hans"];
            } else {
                [[LanguageManager shared] setLanguage:@"en"];
            }
            [GlobalToast show:@"切换成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"languageChangedCallback" object:nil];
            [tableView reloadData];
        }
    }
}

#pragma mark - action
- (void)buttonStudyAction
{
//    NSMutableArray *arrM = [NSMutableArray array];
//    
//    for (int i = 1; i < 10; i++) {
//        NSData *data = [BluetoothMessage messageWith:i+40];
//        [arrM addObject:data];
//    }
    
    NSData *data = [BluetoothMessage messageWith:36 pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)switchAction:(UISwitch *)sender
{
    BOOL isOpen = sender.on;
    NSLog(@"===========结果==%d",isOpen);
    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:@"zeroAutoPlay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
- (void)deleteDevice {
    [[MyBluetoothManager sharedInstance] clear];
    
//    [self switchToHomeVC];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);//退出
    });
}

- (void)switchToHomeVC {
    UIWindow *window = nil;

    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
        }
    } else {
        window = UIApplication.sharedApplication.keyWindow;
    }

    ViewController *homeVC = [ViewController new];
    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:homeVC];

    window.rootViewController = nav;

    // 可选：切换动画
    [UIView transitionWithView:window
                      duration:0.35
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

- (void)parameterSetting {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"参数设置"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"参数";
//        tf.secureTextEntry = YES;
        tf.keyboardType = UIKeyboardTypeDecimalPad;
    }];

    UIAlertAction *confirm =
    [UIAlertAction actionWithTitle:@"确认"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {

        NSString *newPwd = alert.textFields[0].text;

        [self packageDataToSend:newPwd];
//        [self savePassword:newPwd];
    }];

    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changePassword {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"修改密码"
                                        message:@"请输入6位数字"
                                 preferredStyle:UIAlertControllerStyleAlert];

//    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
//        tf.placeholder = @"旧密码";
//        tf.secureTextEntry = YES;
//    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"新密码";
//        tf.secureTextEntry = YES;
        tf.keyboardType = UIKeyboardTypeNumberPad;
    }];

    UIAlertAction *confirm =
    [UIAlertAction actionWithTitle:@"确认"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {

//        NSString *oldPwd = alert.textFields[0].text;
        NSString *newPwd = alert.textFields[0].text;

//        NSString *saved = [KeychainTool loadPassword];
//
//        if (![oldPwd isEqualToString:saved]) {
//            [self showError:@"旧密码不正确"];
//            return;
//        }

        [self savePassword:newPwd];
//        [self showSuccess:@"密码已修改"];
    }];

    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

// 保存密码
- (void)savePassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password
                                              forKey:@"SettingsPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GlobalToast show:[NSString stringWithFormat:@"修改成功：%@",password]];
}

- (void)packageDataToSend:(NSString *)dataStr
{
    
    
    NSData *data = [BluetoothMessage packetMessageWithData:@{}];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

#pragma mark - Notice
- (void)updateMototList:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
