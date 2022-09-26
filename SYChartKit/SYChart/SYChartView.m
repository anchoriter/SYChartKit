//
//  SYChartView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartView.h"
#import "SYChartLegendView.h"
#import "SYChartLineGraphView.h"
#import "SYChartDoubleAxisLineGraphView.h"
#import "SYChartLegendExpandView.h"
#import "SYChartStackedBarView.h"
#import "SYChartWaterfallBarView.h"
#import "SYChartScatterView.h"
#import "SYChartCommentView.h"
#import "SYChartBarLineDoubleAxisGraphView.h"

@interface SYChartView ()
/// 配置和数据
@property (nonatomic, strong) SYChartBaseModel *chartModel;

@property (nonatomic, strong) SYChartCommentView *chartView;
@end
@implementation SYChartView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
/// 绑定数据
-(void)bindChartViewModel:(SYChartBaseModel *)chartModel{
    self.chartModel = chartModel;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat legendTop = 0;
    SYChartLegendView *legendView;
    if (chartModel.chartOptions.legendPosition != SYChartLegendPosition_None) {
        legendView = [[SYChartLegendView alloc] init];
        if (chartModel.chartOptions.legendType == SYChartLegendType_Expand) {
            SYChartLegendExpandView *legendExpandView = [[SYChartLegendExpandView alloc] init];
            [legendExpandView bindChartViewModel:chartModel];
            legendView = legendExpandView;
            
            if (chartModel.chartOptions.showSelected) {
                NSArray *yArray = self.chartModel.dataInfo.datas[0];
                [legendExpandView showLegendDataWithIndex:yArray.count-1];
            }
            
            legendTop = 16;
        }
        if ([self.delegate respondsToSelector:@selector(chartViewDelegateCustomLegendView)]) {
            // 自定义图例
            legendView = [self.delegate chartViewDelegateCustomLegendView];
        }
        [self addSubview:legendView];
        
        NSMutableArray *titleArray = [NSMutableArray array];
        NSMutableArray *colorArray = [NSMutableArray array];
        for (int i=0; i<chartModel.dataInfo.columnMetas.count; i++) {
            SYChartColumnMetaModel *metaModel = chartModel.dataInfo.columnMetas[i];
            if (i>0) {
                [titleArray addObject:metaModel.name];
                [colorArray addObject:metaModel.color];
            }
        }
        
//        CGSize itemSize = CGSizeMake(7*kScreenScale, 7*kScreenScale);
        CGSize itemSize = CGSizeMake(6*kScreenScale, 3*kScreenScale);

        [legendView setLegendTitleArray:titleArray colorArray:colorArray itemSize:itemSize];
    }
    
    if (chartModel.chartOptions.chartType == SYChartType_Line) {
        // 曲线
        SYChartLineGraphView *lineGraphView = [[SYChartLineGraphView alloc] init];
        lineGraphView.delegate = self.delegate;
        [self addSubview:lineGraphView];
        self.chartView = lineGraphView;
        
        if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_None) {
            lineGraphView.frame = CGRectMake(0, 0, self.width, self.height);
        }else{
            // 图例
            if (legendView) {
                lineGraphView.selectedIndexBlock = ^(NSInteger index) {
                    [legendView showLegendDataWithIndex:index];
                };
                
                CGFloat legendHeight = chartModel.chartOptions.legendHeight;
                if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Bottom){
                    lineGraphView.frame = CGRectMake(0, 0, self.width, self.height-legendHeight-chartModel.chartOptions.legendChartSpace);
                    
                    legendView.frame = CGRectMake(0, self.height-legendHeight, self.width, legendHeight);
                }else if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Top){
                    legendView.frame = CGRectMake(0, legendTop, self.width, legendHeight);
                    
                    lineGraphView.frame = CGRectMake(0, legendView.bottom+chartModel.chartOptions.legendChartSpace, self.width, self.height-legendView.bottom-chartModel.chartOptions.legendChartSpace);
                }
            }
        }
        
        [lineGraphView bindChartViewModel:chartModel];
    }else if (chartModel.chartOptions.chartType == SYChartType_Line_DoubleAxis){// 双轴曲线图
        SYChartDoubleAxisLineGraphView *lineGraphView = [[SYChartDoubleAxisLineGraphView alloc] init];
        lineGraphView.delegate = self.delegate;
        [self addSubview:lineGraphView];
        self.chartView = lineGraphView;
        
        if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_None) {
            lineGraphView.frame = CGRectMake(0, 0, self.width, self.height);
        }else{
            // 图例
            if (legendView) {
                lineGraphView.selectedIndexBlock = ^(NSInteger index) {
                    [legendView showLegendDataWithIndex:index];
                };
                
                CGFloat legendHeight = chartModel.chartOptions.legendHeight;
                if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Bottom){
                    lineGraphView.frame = CGRectMake(0, 0, self.width, self.height-legendHeight-chartModel.chartOptions.legendChartSpace);
                    
                    legendView.frame = CGRectMake(0, self.height-legendHeight, self.width, legendHeight);
                }else if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Top){
                    legendView.frame = CGRectMake(0, legendTop, self.width, legendHeight);
                    
                    lineGraphView.frame = CGRectMake(0, legendView.bottom+chartModel.chartOptions.legendChartSpace, self.width, self.height-legendView.bottom-chartModel.chartOptions.legendChartSpace);
                }
            }
        }
        
        [lineGraphView bindChartViewModel:chartModel];
    }else if (chartModel.chartOptions.chartType == SYChartType_Bar){// 堆积状图
        SYChartStackedBarView *stackedBarView = [[SYChartStackedBarView alloc] init];
        stackedBarView.delegate = self.delegate;
        [self addSubview:stackedBarView];
        self.chartView = stackedBarView;
        
        if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_None) {
            stackedBarView.frame = CGRectMake(0, 0, self.width, self.height);
        }else{
            // 图例
            if (legendView) {
                stackedBarView.selectedIndexBlock = ^(NSInteger index) {
                    [legendView showLegendDataWithIndex:index];
                };
                
                CGFloat legendHeight = chartModel.chartOptions.legendHeight;
                if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Bottom){
                    stackedBarView.frame = CGRectMake(0, 0, self.width, self.height-legendHeight-chartModel.chartOptions.legendChartSpace);
                    
                    legendView.frame = CGRectMake(0, self.height-legendHeight, self.width, legendHeight);
                }else if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Top){
                    legendView.frame = CGRectMake(0, legendTop, self.width, legendHeight);
                    
                    stackedBarView.frame = CGRectMake(0, legendView.bottom+chartModel.chartOptions.legendChartSpace, self.width, self.height-legendView.bottom-chartModel.chartOptions.legendChartSpace);
                }
            }
        }
        
        [stackedBarView bindChartViewModel:chartModel];
    }else if (chartModel.chartOptions.chartType == SYChartType_WaterfallBar){// 瀑布图
        SYChartWaterfallBarView *waterfallBarView  = [[SYChartWaterfallBarView alloc] init];
        waterfallBarView.delegate = self.delegate;
        [self addSubview:waterfallBarView];
        self.chartView = waterfallBarView;
        
        if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_None) {
            waterfallBarView.frame = CGRectMake(0, 0, self.width, self.height);
        }else{
            // 图例
            if (legendView) {
                waterfallBarView.selectedIndexBlock = ^(NSInteger index) {
                    [legendView showLegendDataWithIndex:index];
                };
                
                CGFloat legendHeight = chartModel.chartOptions.legendHeight;
                if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Bottom){
                    waterfallBarView.frame = CGRectMake(0, 0, self.width, self.height-legendHeight-chartModel.chartOptions.legendChartSpace);
                    
                    legendView.frame = CGRectMake(0, self.height-legendHeight, self.width, legendHeight);
                }else if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Top){
                    legendView.frame = CGRectMake(0, legendTop, self.width, legendHeight);
                    
                    waterfallBarView.frame = CGRectMake(0, legendView.bottom+chartModel.chartOptions.legendChartSpace, self.width, self.height-legendView.bottom-chartModel.chartOptions.legendChartSpace);
                }
            }
        }
        
        [waterfallBarView bindChartViewModel:chartModel];
    }else if (chartModel.chartOptions.chartType == SYChartType_Scatter || chartModel.chartOptions.chartType == SYChartType_Bubble){// 散点图气泡图
        SYChartScatterView *scatterView = [[SYChartScatterView alloc] init];
        scatterView.delegate = self.delegate;
        [self addSubview:scatterView];
        self.chartView = scatterView;
        
        scatterView.frame = CGRectMake(0, 0, self.width, self.height);
        [scatterView bindChartViewModel:chartModel];
    }else if (chartModel.chartOptions.chartType == SYChartType_BarLine_DoubleAxis){
        // 多柱曲线双轴图
        SYChartBarLineDoubleAxisGraphView *barLineView = [[SYChartBarLineDoubleAxisGraphView alloc] init];
        barLineView.delegate = self.delegate;
        [self addSubview:barLineView];
        self.chartView = barLineView;
        
        if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_None) {
            barLineView.frame = CGRectMake(0, 0, self.width, self.height);
        }else{
            // 图例
            if (legendView) {
                barLineView.selectedIndexBlock = ^(NSInteger index) {
                    [legendView showLegendDataWithIndex:index];
                };
                
                CGFloat legendHeight = chartModel.chartOptions.legendHeight;
                if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Bottom){
                    barLineView.frame = CGRectMake(0, 0, self.width, self.height-legendHeight-chartModel.chartOptions.legendChartSpace);
                    
                    legendView.frame = CGRectMake(0, self.height-legendHeight, self.width, legendHeight);
                }else if (chartModel.chartOptions.legendPosition == SYChartLegendPosition_Top){
                    legendView.frame = CGRectMake(0, legendTop, self.width, legendHeight);
                    
                    barLineView.frame = CGRectMake(0, legendView.bottom+chartModel.chartOptions.legendChartSpace, self.width, self.height-legendView.bottom-chartModel.chartOptions.legendChartSpace);
                }
            }
        }
        
        [barLineView bindChartViewModel:chartModel];
    }
}

/// 设置选中位置
-(void)changeSelectedWithIndex:(NSInteger)index{
    [self.chartView changeSelectedWithIndex:index];
}
/// 设置选中项
-(void)changeSelectedWithObject:(id)obj{
    [self.chartView changeSelectedWithObject:obj];
}
/// 隐藏指示器竖线
-(void)hiddenMarkerLine{
    [self.chartView hiddenMarkerLine];
}
@end
