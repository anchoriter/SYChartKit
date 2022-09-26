//
//  OneViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/23.
//

#import "OneViewController.h"
#import "SYSwitchView.h"

@interface OneViewController ()<SYChartViewDelegate>
/// X轴坐标风格切换
@property (nonatomic, strong) SYSwitchView *xLabelStyleSwitch;
/// 浮窗风格切换
@property (nonatomic, strong) SYSwitchView *markViewStyleSwitch;
/// 图例风格切换
@property (nonatomic, strong) SYSwitchView *legendStyleSwitch;
/// 曲线折线风格切换
@property (nonatomic, strong) SYSwitchView *lineStyleSwitch;
@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self creatSubViews];
    
    [self loadChartData];
}
/// 创建子控件
-(void)creatSubViews{
    [self.view addSubview:self.chartView];
    self.chartView.frame = CGRectMake(10, 10, self.view.width-10*2, 350*kScreenScale);
    
    [self.view addSubview:self.xLabelStyleSwitch];
    self.xLabelStyleSwitch.frame = CGRectMake(10, self.chartView.bottom+20, 200, 20);
    
    [self.view addSubview:self.markViewStyleSwitch];
    self.markViewStyleSwitch.frame = CGRectMake(10, self.xLabelStyleSwitch.bottom+20, 200, 20);

    [self.view addSubview:self.legendStyleSwitch];
    self.legendStyleSwitch.frame = CGRectMake(10, self.markViewStyleSwitch.bottom+20, 200, 20);
    
    [self.view addSubview:self.lineStyleSwitch];
    self.lineStyleSwitch.frame = CGRectMake(10, self.legendStyleSwitch.bottom+20, 200, 20);
}
/// 加载图表数据
-(void)loadChartData{
    if (KStringIsEmpty(self.jsonName)){
        return;
    }
    // 请求接口数据，此处以本地json数据替代
    NSDictionary *dict = [SYChartTool readLocalJsonFileWithName:self.jsonName];
    // 解析为本图表依赖的标准图表数据结构model
    // columnMetas中的index表示对应下标的datas数组中的数据
    SYChartBaseModel *chartModel = [SYChartBaseModel mj_objectWithKeyValues:dict[@"data"]];
    if (chartModel.dataInfo.datas.count>0) {
        SYChartOptions *chartOptions = [[SYChartOptions alloc] init];
        chartOptions.chartType = SYChartType_Line;
        NSString *chartYTitle = @"优惠率(%))";
        if(!KStringIsEmpty(chartModel.dataInfo.extra.y_title)){
            chartYTitle = chartModel.dataInfo.extra.y_title;
        }
        chartOptions.chartYTitle = chartYTitle;
        chartOptions.topMargin = 45*kScreenScale;
        chartOptions.paddingLeft = 10*kScreenScale;
        chartOptions.paddingRight = 10*kScreenScale;
        
        chartOptions.showMarkLine = YES;// 展示浮窗标线

        if (self.markViewStyleSwitch.onStatus) {
            chartOptions.hiddenMarkDot = YES;
            chartOptions.showTopDateView = YES;
            chartOptions.showSelected = YES;
        }else{
            chartOptions.showMarkView = YES;
            chartOptions.autoHiddenMarkView = YES;
        }
        
        if (chartModel.dataInfo.datas.count <= 2) {
            chartOptions.legendPosition = SYChartLegendPosition_None;// 不展示图例
        }else{
            chartOptions.legendPosition = SYChartLegendPosition_Bottom;// 展示底部图例
        }
        chartOptions.legendColumnNum = 3;
        if (self.legendStyleSwitch.onStatus) {
            chartOptions.legendType = SYChartLegendType_Expand;// 拓展样式图例
            chartOptions.legendPosition = SYChartLegendPosition_Top;// 展示顶部图例
            chartOptions.legendHeight = 60*kScreenScale;
            chartOptions.legendChartSpace = 10*kScreenScale;
            
            // 拓展样式图例时，建议默认显示选中，并设置为不自动隐藏
            chartOptions.showSelected = YES;
            chartOptions.autoHiddenMarkView = NO;
            chartOptions.showTopDateView = YES;
        }else{
            chartOptions.legendType = SYChartLegendType_Normal;// 普通样式图例
            chartOptions.legendHeight = 20*kScreenScale;
            chartOptions.legendChartSpace = 0*kScreenScale;
        }
        
        chartOptions.showUnitNum = YES;
        
        chartOptions.firstXLabelIndent = YES;// 需要缩进
        if (self.xLabelStyleSwitch.onStatus) {
            chartOptions.xLabelMustFlat = YES;// 需要平放
        }else{
            chartOptions.xLabelMustFlat = NO;// 自动判断
        }
        
        chartOptions.xLabelFlatMaxWidth = 0;
        
        chartOptions.lineNum = 4;// 限制行数
        chartOptions.forceYShowInteger = YES;// 强制整数
        
        chartOptions.barMinSpace = 2*kScreenScale;
        
        chartModel.chartOptions = chartOptions;
        
        // 配置线的颜色、面积、浮窗
        NSArray *colorArray = @[@"#787878", @"#FC3737", @"#1E1F20"];
        if(!KStringIsEmpty(chartModel.dataInfo.extra.chartFileColor)){
            NSMutableArray *chartFileColor = [NSMutableArray arrayWithObject:@"#787878"];
            [chartFileColor addObjectsFromArray:[chartModel.dataInfo.extra.chartFileColor componentsSeparatedByString:@","]];
            colorArray = chartFileColor;
        }
        for (int i=0; i<chartModel.dataInfo.columnMetas.count; i++) {
            SYChartColumnMetaModel *metaModel = chartModel.dataInfo.columnMetas[i];
            
            if (self.lineStyleSwitch.onStatus) {
                metaModel.showType = SYChartShowType_Curve;//曲线
            }else{
                // 默认曲线 SYChartShowType_Line
            }
            
            NSString *color = colorArray[i%colorArray.count];
            metaModel.color = color;
            if (i == 1) {// 渐变色面积填充
                metaModel.showAreaLayer = YES;
            }

            if ([metaModel.name containsString:@"率"]) {
                // 率要除100
                if (i<chartModel.dataInfo.datas.count) {
                    NSMutableArray *rateArray = [NSMutableArray array];
                    NSArray *tempArray = chartModel.dataInfo.datas[i];
                    if (tempArray.count>0) {
                        for (id obj in tempArray) {
                            NSString *rateStr = @"--";
                            if ([obj isKindOfClass:[NSNumber class]]) {
                                NSNumber *num = obj;
                                if (!num) {
                                    CGFloat objFloat = [num doubleValue];
                                    
                                    rateStr = [NSString stringWithFormat:@"%.2f%%", objFloat];
                                }
                            }else if ([obj isKindOfClass:[NSString class]]){
                                if (!KStringIsEmpty(obj)) {
                                    CGFloat objFloat = [obj doubleValue];
                                    
                                    rateStr = [NSString stringWithFormat:@"%.2f%%", objFloat];
                                }
                            }
                            [rateArray addObject:rateStr];
                        }
                    }

                    NSMutableArray *datas = [NSMutableArray arrayWithArray:chartModel.dataInfo.datas];
                    [datas replaceObjectAtIndex:i withObject:rateArray];
                    chartModel.dataInfo.datas = datas;
                }
            }
        }
        [self.chartView bindChartViewModel:chartModel];

    }else{
        // 无数据，可以在此覆盖缺省图
    }
}

# pragma mark - SYChartViewDelegate
/// 纵轴标题
-(NSString *)chartViewWithModel:(SYChartBaseModel *)chartModel unit:(ChartUnitNum)unit{
    /// 可在此自定义纵轴标题文本拼接方案
    NSString *yTitle = @"优惠率(%)";
    if (chartModel.dataInfo.columnMetas.count>1) {
        yTitle = @"优惠率";
        if(!KStringIsEmpty(chartModel.dataInfo.extra.y_title)){
            yTitle = chartModel.dataInfo.extra.y_title;
        }
        if (!KStringIsEmpty(unit.unit)) {
            yTitle = [NSString stringWithFormat:@"%@(%@%%)", yTitle, unit.unit];
        }else{
            yTitle = [NSString stringWithFormat:@"%@(%%)", yTitle];
        }
    }
    
    return yTitle;
}


# pragma mark - 懒加载
-(SYSwitchView *)xLabelStyleSwitch{
    if (!_xLabelStyleSwitch) {
        _xLabelStyleSwitch = [[SYSwitchView alloc] init];
        [_xLabelStyleSwitch setLableWidth:160];
        [_xLabelStyleSwitch setSwitchLabelText:@"X轴强制横放显示"];
        [_xLabelStyleSwitch setOnStatus:NO];
        _xLabelStyleSwitch.switchLabelDirection = 1;
        _xLabelStyleSwitch.switchLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        @weakify(self);
        _xLabelStyleSwitch.changeBlock = ^(BOOL OnStatus) {
            @strongify(self);
            [self loadChartData];
        };
    }
    return _xLabelStyleSwitch;
}
-(SYSwitchView *)markViewStyleSwitch{
    if (!_markViewStyleSwitch) {
        _markViewStyleSwitch = [[SYSwitchView alloc] init];
        [_markViewStyleSwitch setLableWidth:160];
        [_markViewStyleSwitch setSwitchLabelText:@"切换浮窗风格"];
        [_markViewStyleSwitch setOnStatus:NO];
        _markViewStyleSwitch.switchLabelDirection = 1;
        _markViewStyleSwitch.switchLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        @weakify(self);
        _markViewStyleSwitch.changeBlock = ^(BOOL OnStatus) {
            @strongify(self);
            [self loadChartData];
        };
    }
    return _markViewStyleSwitch;
}
-(SYSwitchView *)legendStyleSwitch{
    if (!_legendStyleSwitch) {
        _legendStyleSwitch = [[SYSwitchView alloc] init];
        [_legendStyleSwitch setLableWidth:160];
        [_legendStyleSwitch setSwitchLabelText:@"切换图例风格"];
        [_legendStyleSwitch setOnStatus:NO];
        _legendStyleSwitch.switchLabelDirection = 1;
        _legendStyleSwitch.switchLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        @weakify(self);
        _legendStyleSwitch.changeBlock = ^(BOOL OnStatus) {
            @strongify(self);
            [self loadChartData];
            
            /*
             1.当显示拓展图例时，黑色浮窗中的数据已经在图例中展示
             2.故黑色浮窗不再适合当前场景，不允许切换浮窗风格，强制改为仅显示X轴信息的简化浮窗
             */
            self.markViewStyleSwitch.userInteractionEnabled = !OnStatus;
            if (OnStatus){
                self.markViewStyleSwitch.alpha = 0.3;
            }else{
                self.markViewStyleSwitch.alpha = 1;
            }
        };
    }
    return _legendStyleSwitch;
}

-(SYSwitchView *)lineStyleSwitch{
    if (!_lineStyleSwitch) {
        _lineStyleSwitch = [[SYSwitchView alloc] init];
        [_lineStyleSwitch setLableWidth:160];
        [_lineStyleSwitch setSwitchLabelText:@"切换曲线折线风格"];
        [_lineStyleSwitch setOnStatus:NO];
        _lineStyleSwitch.switchLabelDirection = 1;
        _lineStyleSwitch.switchLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        @weakify(self);
        _lineStyleSwitch.changeBlock = ^(BOOL OnStatus) {
            @strongify(self);
            [self loadChartData];
        };
    }
    return _lineStyleSwitch;
}
@end
