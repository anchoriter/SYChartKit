//
//  SubBaseViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/26.
//

#import "SubBaseViewController.h"

@interface SubBaseViewController ()

@end

@implementation SubBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
}

# pragma mark - 懒加载
-(SYChartView *)chartView{
    if (!_chartView) {
        _chartView = [[SYChartView alloc] init];
        _chartView.backgroundColor = [UIColor whiteColor];
        _chartView.delegate = self;
    }
    return _chartView;
}
@end
