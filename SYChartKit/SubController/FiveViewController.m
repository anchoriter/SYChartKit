//
//  FiveViewController.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/26.
//

#import "FiveViewController.h"

@interface FiveViewController ()<SYChartViewDelegate>

@end

@implementation FiveViewController

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
        chartOptions.topMargin = 16*kScreenScale;
        chartOptions.bottomMargin = 16*kScreenScale;
        chartOptions.paddingLeft = 16*kScreenScale;
        chartOptions.paddingRight = 16*kScreenScale;
        
        chartOptions.legendPosition = SYChartLegendPosition_None;
        chartOptions.showMarkLine = NO;
        chartOptions.showTopDateView = NO;
        chartOptions.showUnitNum = NO;
        chartOptions.showSelected = YES;
                
        // 默认选中第一象限
        if (!chartModel.dataInfo.extra) {
            SYChartExtraModel *extra = [[SYChartExtraModel alloc] init];
            chartModel.dataInfo.extra = extra;
        }
        NSArray *quadrantDescArray = chartModel.dataInfo.extra.quadrantDescArray;
        if (quadrantDescArray.count > 0) {
            NSArray *colorArray = @[@"#FF2D2D", @"#FF992C", @"#2A9AFE", @"#32CCA6"];
            NSMutableArray *scatterInfo = [NSMutableArray array];
            for (int i=0; i<quadrantDescArray.count; i++) {
                NSString *quadrantDesc = quadrantDescArray[i];
                
                SYChartScatterExtraModel *eModel = [[SYChartScatterExtraModel alloc] init];
                eModel.name = quadrantDesc;
                eModel.index = i+1;
                
                NSString *color = colorArray[i%colorArray.count];
                eModel.color = color;
                
                [scatterInfo addObject:eModel];
            }
            chartModel.dataInfo.extra.scatterInfo = scatterInfo;
        }
        
        if (chartModel.dataInfo.columnMetas.count > 2) {
            chartOptions.chartType = SYChartType_Bubble;// 气泡图
        }else{
            chartOptions.chartType = SYChartType_Scatter;// 散点图
        }
        
        chartModel.chartOptions = chartOptions;

        [self.chartView bindChartViewModel:chartModel];

    }else{
        // 无数据，可以在此覆盖缺省图
    }
}

# pragma mark - SYChartViewDelegate
/// 选中项
-(void)chartViewDelegateWithSelectedObject:(id)obj{
    if ([obj isKindOfClass:[NSString class]] && !KStringIsEmpty(obj)) {
        NSString *title = obj;
        DLog(@"点击了====%@", title);
    }
}
@end
