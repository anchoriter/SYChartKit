//
//  TwoViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/26.
//

#import "TwoViewController.h"

@interface TwoViewController ()<SYChartViewDelegate>

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self creatSubViews];
    
    [self loadChartData];
}
/// 创建子控件
-(void)creatSubViews{
    [self.view addSubview:self.chartView];
    self.chartView.frame = CGRectMake(10, 10, self.view.width-10*2, 350*kScreenScale);
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
        chartOptions.chartType = SYChartType_Line_DoubleAxis;// 双轴图
        NSString *chartYTitle = @"优惠率(%))";
        if(!KStringIsEmpty(chartModel.dataInfo.extra.y_title)){
            chartYTitle = chartModel.dataInfo.extra.y_title;
        }
        chartOptions.chartYTitle = chartYTitle;
        chartOptions.topMargin = 45*kScreenScale;
        chartOptions.paddingLeft = 10*kScreenScale;
        chartOptions.paddingRight = 10*kScreenScale;
        
        chartOptions.showMarkLine = YES;// 展示浮窗标线

        chartOptions.hiddenMarkDot = YES;
        chartOptions.showTopDateView = YES;
        chartOptions.showSelected = YES;
        
        chartOptions.legendColumnNum = 3;
        chartOptions.legendType = SYChartLegendType_Expand;// 拓展样式图例
        chartOptions.legendPosition = SYChartLegendPosition_Top;// 展示顶部图例
        chartOptions.legendHeight = 60*kScreenScale;
        chartOptions.legendChartSpace = 10*kScreenScale;
        
        chartOptions.showUnitNum = YES;
        
        chartOptions.firstXLabelIndent = YES;// 需要缩进
        chartOptions.xLabelMustFlat = NO;// 自动判断
        
        chartOptions.xLabelFlatMaxWidth = 0;
        
        chartOptions.lineNum = 4;// 限制行数
        chartOptions.forceYShowInteger = YES;// 强制整数
        
        chartOptions.barMinSpace = 2*kScreenScale;
        
        chartModel.chartOptions = chartOptions;
        
        // 配置线的颜色、面积、浮窗
        NSArray *colorArray = @[@"#787878", @"#FC3737", @"#47BDB9"];
        if(!KStringIsEmpty(chartModel.dataInfo.extra.chartFileColor)){
            NSMutableArray *chartFileColor = [NSMutableArray arrayWithObject:@"#787878"];
            [chartFileColor addObjectsFromArray:[chartModel.dataInfo.extra.chartFileColor componentsSeparatedByString:@","]];
            colorArray = chartFileColor;
        }
        for (int i=0; i<chartModel.dataInfo.columnMetas.count; i++) {
            SYChartColumnMetaModel *metaModel = chartModel.dataInfo.columnMetas[i];

            NSString *color = colorArray[i%colorArray.count];
            metaModel.color = color;
            if (i == 1) {// 渐变色面积填充
                metaModel.showAreaLayer = YES;
            }

            if ([metaModel.name containsString:@"率"]) {
                metaModel.isRightAxis = YES;
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
    NSString *yTitle = nil;
    if (chartModel.chartOptions.chartType == SYChartType_Line_DoubleAxis && chartModel.dataInfo.columnMetas.count>1) {
        SYChartColumnMetaModel *metaModel = chartModel.dataInfo.columnMetas[1];
        yTitle = metaModel.name;
        if (!KStringIsEmpty(unit.unit)) {
            yTitle = [NSString stringWithFormat:@"%@(%@)", metaModel.name, unit.unit];
        }
    }
    
    return yTitle;
}
/// 右侧纵轴标题
-(NSString *)chartViewWithModel:(SYChartBaseModel *)chartModel rightUnit:(ChartUnitNum)unit{
    NSString *yTitle = nil;
    if (chartModel.chartOptions.chartType == SYChartType_Line_DoubleAxis) {
        for (SYChartColumnMetaModel *metaModel in chartModel.dataInfo.columnMetas) {
            if ([metaModel.name containsString:@"利润率"]) {
                yTitle = [NSString stringWithFormat:@"%@(%@%%)", metaModel.name, unit.unit];
            }
        }
        
    }
    return yTitle;
}

@end
