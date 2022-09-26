//
//  FourViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/26.
//

#import "FourViewController.h"

@interface FourViewController ()

@end

@implementation FourViewController

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
        chartOptions.chartType = SYChartType_WaterfallBar;// 瀑布图
        
        chartOptions.barWidth = 14*kScreenScale;
        chartOptions.startPointPadding = 10*kScreenScale;
        
        chartOptions.topMargin = 45*kScreenScale;
        
        chartOptions.chartYTitle = @"单位：";
        chartOptions.showUnitNum = YES;
        chartOptions.lineNum = 4;// 限制行数
        chartOptions.forceYShowInteger = YES;// 强制整数
        chartOptions.limitMinY = YES;// 限制负数
        
        chartModel.chartOptions = chartOptions;
        
        // 配置线的颜色、面积、浮窗
        NSArray *colorArray = @[@"#787878", @"#FD766A"];
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
