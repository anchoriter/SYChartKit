//
//  ThreeViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/26.
//

#import "ThreeViewController.h"

@interface ThreeViewController ()


@end

@implementation ThreeViewController
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
        chartOptions.chartType = SYChartType_Bar;// 柱状图
        
        chartOptions.chartYTitle = @"单位：";
        chartOptions.topMargin = 45*kScreenScale;
        chartOptions.paddingLeft = 10*kScreenScale;
        chartOptions.paddingRight = 10*kScreenScale;
        
        chartOptions.startPointPadding = 5*kScreenScale;
        chartOptions.barWidth = 12*kScreenScale;
        
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
        }
        [self.chartView bindChartViewModel:chartModel];

    }else{
        // 无数据，可以在此覆盖缺省图
    }
}

@end
