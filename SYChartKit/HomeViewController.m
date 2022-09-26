//
//  HomeViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "HomeViewController.h"
#import "SYChartTool.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>
 
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *listArray;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"SYChartKit";
    
    [self.view addSubview:self.listTableView];
    
    // 图表类型
    NSArray *array1 = @[@{@"title":@"曲线折线图", @"jsonName":@"ChartData_1"},
                       @{@"title":@"曲线双轴图", @"jsonName":@"ChartData_2"},
                       @{@"title":@"柱状图", @"jsonName":@"ChartData_3"},
                       @{@"title":@"堆积图", @"jsonName":@"ChartData_1"},
                       @{@"title":@"瀑布图", @"jsonName":@"ChartData_4"},
                       @{@"title":@"散点图", @"jsonName":@"ChartData_5"},
                       @{@"title":@"气泡图", @"jsonName":@"ChartData_6"},
                       @{@"title":@"多柱曲线双轴图", @"jsonName":@"ChartData_7"}];
    // 其它
    NSArray *array2 = @[@{@"title":@"QQ", @"jsonName":@"781117967"},
                        @{@"title":@"简书", @"jsonName":@"https://www.jianshu.com/u/3527bcc4f266?u_atoken=2fa8bcaf-42e9-48d0-94ea-2899842fb080&u_asession=01oRcGx9ejxiSP1X91k7IhVp3j7upgw50-b3pJmjXi8YbyDNCXV2RK-Yu_N-Elc1yoX0KNBwm7Lovlpxjd_P_q4JsKWYrT3W_NKPr8w6oU7K_-BrjYRz-JD2seE03y3eUYkC1LUOsbnJoxzzl_EpVkQGBkFo3NEHBv0PZUm6pbxQU&u_asig=05ZlLDwAFXa4BVhn2Fh7CLozQ8MDlJExIDsdRS6MLgPUyvcHCF7-H-HmEV2e9kgW3_ZnGEc31xubm_-XAv7yHNub6nOVAoF_kSta-sFThZSeu2PqPwrh2iB2SVpfSvwAl4NKebTMYTRe9XxT-l1tNB8AelMFxqDoH_ZaA--4bGrFv9JS7q8ZD7Xtz2Ly-b0kmuyAKRFSVJkkdwVUnyHAIJzRN54yw7ikB1_997hEh2jQLiNUginp45j3BurNwBxkQxUDrMH9U5oL9icxwFsJSlo-3h9VXwMyh6PgyDIVSG1W_1zGaKI5GbL3KGZU0MetYpLAeUFLSCpKnaF8xNzDD3ZBSgk1ckqTbrJWLbhcXjirpionMxUJDPWEoKCHi3geyqmWspDxyAEEo4kbsryBKb9Q&u_aref=Bu4C5%2FoW%2BMTEbt8Sf9%2FBsHP4Pjs%3D"}];
    
    self.listArray = @[array1, array2];
    
    [self.listTableView reloadData];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ListHeader"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"ListHeader"];
        header.backgroundColor = [UIColor clearColor];
        header.contentView.backgroundColor = [UIColor clearColor];
    }
    UILabel *titleLabel = [header viewWithTag:11111];
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KWidth-10*2, 50)];
        titleLabel.tag = 11111;
        titleLabel.font = kFontMediumScale(18);
        titleLabel.textColor = [UIColor blackColor];
        [header addSubview:titleLabel];
    }
    if (section == 0) {
        titleLabel.text = @"图表类型";
    }else if (section == 1){
        titleLabel.text = @"其它";
    }else{
        titleLabel.text = nil;
    }
    
    return header;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.listArray[section];
    return arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"cellIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = RGB(51, 51, 51);
    cell.detailTextLabel.textColor = RGB(51, 51, 51);
    
    NSArray *arr = self.listArray[indexPath.section];
    if (indexPath.row < arr.count) {
        NSDictionary *cellDict = arr[indexPath.row];
        cell.textLabel.text = cellDict[@"title"];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.listArray[indexPath.section];
    if (indexPath.row < arr.count) {
        NSDictionary *cellDict = arr[indexPath.row];
        NSString *jsonName = cellDict[@"jsonName"];
        NSString *title = cellDict[@"title"];
        
        if (!KStringIsEmpty(title) && !KStringIsEmpty(jsonName)){
            if ([title isEqualToString:@"曲线折线图"]){
                OneViewController *vc = [[OneViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"曲线双轴图"]){
                TwoViewController *vc = [[TwoViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"柱状图"]){
                ThreeViewController *vc = [[ThreeViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"堆积图"]){
                ThreeViewController *vc = [[ThreeViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"瀑布图"]){
                FourViewController *vc = [[FourViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"散点图"]){
                FiveViewController *vc = [[FiveViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"气泡图"]){
                FiveViewController *vc = [[FiveViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([title isEqualToString:@"多柱曲线双轴图"]){
                SixViewController *vc = [[SixViewController alloc] init];
                vc.jsonName = jsonName;
                vc.title = title;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
            
            
            // 其它
            else if ([title isEqualToString:@"QQ"]){
                [UIPasteboard generalPasteboard].string = jsonName;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"QQ已复制" message:jsonName preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"打开QQ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    // QQ好友
                    NSString *openString = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&card_type=wpa&source=external",jsonName];
                    NSURL *openUrl = [NSURL URLWithString:openString];
                
                    NSURL *urlII = [NSURL URLWithString:@"mqq://"];
                    // 是否安装了qq
                    if ([[UIApplication sharedApplication] canOpenURL:urlII]) {
                        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                            if (@available(iOS 10.0, *)) {
                                [[UIApplication sharedApplication] openURL:openUrl options:@{} completionHandler:^(BOOL success) {
                                    if (!success) {
                                        // 跳转QQ失败
                                    }
                                }];
                            }
                        }
                        return;
                    }else{
                        // 未安装QQ
                        return;
                    }
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    
                }]];
                [self presentViewController:alertController animated:YES completion:^{
                    
                }];
            }else if ([title isEqualToString:@"简书"]){
                [UIPasteboard generalPasteboard].string = jsonName;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"简书地址已复制" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"打开简书" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jsonName] options:@{} completionHandler:^(BOOL success) {
                        if (success){
                            
                        }
                     }];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    
                }]];
                [self presentViewController:alertController animated:YES completion:^{
                    
                }];
            }
        }
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    self.listTableView.frame = CGRectMake(0, 0, width, height);
}
-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _listTableView.estimatedRowHeight = 0;
        _listTableView.estimatedSectionHeaderHeight = 0;
        _listTableView.estimatedSectionFooterHeight = 0;
        _listTableView.backgroundView = nil;
        _listTableView.backgroundColor = [UIColor clearColor];
        _listTableView.bounces = YES;
        //        _listTableView.scrollsToTop = NO;
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    return _listTableView;
}
@end
