//
//  SYChartStackedBarView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartStackedBarView.h"
#import "SYChartTool.h"
#import "SYChartBarItemView.h"


@interface SYChartStackedBarView ()

/// 柱子视图数组
@property (nonatomic, strong) NSMutableArray *barViewArray;
/// 柱子宽度
@property (nonatomic, assign) CGFloat barWidth;

@end
@implementation SYChartStackedBarView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.barViewArray = [NSMutableArray array];
        self.barWidth = 8*kScreenScale;
    }
    return self;
}

/// 重置图表
-(void)resetChart{
    [super resetChart];
    
    for (UIView *v in self.barViewArray) {
        [v removeFromSuperview];
    }

    [self.dotPointArray removeAllObjects];
    [self.pointXArray removeAllObjects];
    
    [self.barViewArray removeAllObjects];
    if (self.chartOptions.barWidth > 0) {
        self.barWidth = self.chartOptions.barWidth;
    }

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

/// 绘制图表
- (void)drawGraphViewUI{
    // 获取所有Y轴合计数据值
    NSMutableArray *dataListArray = [NSMutableArray array];
    
    // 获取所有Y轴合计真实数据值(元素为单柱子堆积数据的集合)
    NSMutableArray *realDataListArray = [NSMutableArray array];
    
    // 取出datas元素中最大长度的数据(数组元素最多)
    NSInteger maxBarCount = 0;
    for (int i=0; i<self.y_axis.count; i++) {
        NSArray *itemArr = self.y_axis[i];
        if (itemArr.count>maxBarCount) {
            maxBarCount = itemArr.count;
        }
    }
    // 堆积图要计算每列的和
    for (int i=0; i<maxBarCount; i++) {
        // 单个柱子所需数据
        NSMutableArray *itemBarDataArray = [NSMutableArray array];
        
        CGFloat num = 0;
        CGFloat objFloat = 0;
        for (int j=0; j<self.y_axis.count; j++) {
            NSArray *itemArr = self.y_axis[j];
            if (i < itemArr.count) {
                id obj = itemArr[i];
                if ([obj isKindOfClass:[NSNumber class]]) {
                    objFloat = [obj doubleValue];
                }else if ([obj isKindOfClass:[NSString class]]){
                    objFloat = [obj doubleValue];
                }
                
                if (self.chartModel.chartOptions.limitMinY && objFloat<0) {// 不能为负数
                    objFloat = 0;
                }
                
                num = num+objFloat;
            }
            
            [itemBarDataArray addObject:@(objFloat)];
        }
        
        [realDataListArray addObject:itemBarDataArray];
        
        [dataListArray addObject:@(num)];
    }

    // y坐标最大值
    CGFloat maxValue = [SYChartTool getMaxValueWithDataArray:dataListArray];

    // y坐标最小值
    CGFloat minValue = [SYChartTool getMinValueWithDataArray:dataListArray];

//    // 转换成图表适合的范围内最大值 并计算最大宽度
//    maxValue = [SYChartTool rangeMaxWithValueMax:maxValue];
    
    // 是否显示负数 （目前暂不支持）
//    BOOL showMinus = minValue<0?YES:NO;
//    CGFloat tempMinValue = [SYChartTool rangeMaxWithValueMax:fabs([@(minValue) floatValue])];
//    if (showMinus) {
//        minValue = -tempMinValue;
//    }else{
//        minValue = tempMinValue;
//    }
    
//    if (self.chartOptions.forceYShowInteger) {
//        CGFloat maxFabsValue = MAX(fabs(maxValue), fabs(minValue));
//        if (maxFabsValue != 0 && maxFabsValue < self.chartOptions.lineNum) {
//            if (fabs(maxValue) > fabs(minValue)) {
//                if (maxValue>0) {
//                    maxValue = self.chartOptions.lineNum;
//                }else if (maxValue < 0){
//                    maxValue = -self.chartOptions.lineNum;
//                }
//            }else{
//                if (minValue>0) {
//                    minValue = self.chartOptions.lineNum;
//                }else if (minValue < 0){
//                    minValue = -self.chartOptions.lineNum;
//                }
//            }
//        }
//    }
    
    /// 获取单位
    ChartUnitNum unitNum = [SYChartTool getUnitNumWithMinValue:minValue maxValue:maxValue rowNum:self.chartOptions.lineNum];
    if (unitNum.unitNum > 1) {
        maxValue = [SYChartTool conversionValueWithOldValue:maxValue unitNum:unitNum];
        minValue = [SYChartTool conversionValueWithOldValue:minValue unitNum:unitNum];
    }
    
    // 转换成图表适合的范围内最大值 并计算最大宽度
    maxValue = [SYChartTool rangeMaxWithValueMax:maxValue];
    
    BOOL showMinus = minValue<0?YES:NO;
    CGFloat tempMinValue = [SYChartTool rangeMaxWithValueMax:fabs([@(minValue) floatValue])];
    if (showMinus) {
        minValue = -tempMinValue;
    }else{
        minValue = tempMinValue;
    }
    self.maxValue = maxValue;
    self.minValue = minValue;
 
    /// Y轴纵坐标单位
    [self setupYTitleWithChartUnit:unitNum];
    if (self.yTitleLabel.hidden) {
        self.chartOptions.topMargin = 10*kScreenScale;
    }
    
    /// 处理横线区间行数和行间差值
    [self handleHorizontalLineRowAndRelativeValue];

    self.startLayerX = self.chartOptions.paddingLeft+self.labelWidth+self.chartOptions.yTitleRightSpace;
    self.contentW = self.width - self.chartOptions.paddingLeft - self.chartOptions.paddingRight;
    self.startLayerW = self.contentW-self.startLayerX-self.chartOptions.layerRightMargin;// +10的操作暂未清楚
    
    /// 因处理X坐标label的放置方向，需要首先绘制X坐标，
    // 绘制横坐标label
    self.pointXSpace = self.startLayerW;
    NSArray *xDataArray = self.chartModel.dataInfo.datas[0];
    if (xDataArray.count>2) {
        self.pointXSpace = (self.startLayerW-self.chartOptions.startPointPadding*2-self.barWidth) / (xDataArray.count-1);
        if (self.pointXSpace < self.barWidth+self.chartOptions.barMinSpace) {
            self.barWidth = self.pointXSpace-self.chartOptions.barMinSpace;
        }
    }

    // 画横坐标
    [self creatXLabelWithXDataArray:xDataArray barMargin:self.barWidth*0.5 + self.chartOptions.startPointPadding];
        
    /// 创建纵坐标控件和横虚线
    [self creatYLabelAndDashLine];
    
    // 空数据情况，y坐标在最下方
    if (maxValue == 0 && minValue == 0) {
        self.zeroY = self.height-self.chartOptions.bottomMargin;
    }

    // 创建所有柱子
    CGFloat avgHeight = self.contentH / self.lineRow;
    for (int i = 0; i < maxBarCount; i++) {
        NSMutableArray *itemBarDataArray = realDataListArray[i];
        
        if (i < self.pointXArray.count) {
            SYChartBarItemView *barItemView = [[SYChartBarItemView alloc] init];
            [self addSubview:barItemView];
            [self.barViewArray addObject:barItemView];
            
            // 求单柱子合计
            double realTotalNum = [[itemBarDataArray valueForKeyPath:@"@sum.doubleValue"] doubleValue];

            double yValue = realTotalNum/unitNum.unitNum;// 单位换算
            if (self.chartModel.chartOptions.limitMinY && yValue<0) {// 不能为负数
                yValue = 0;
            }

            CGFloat barH = 0;
            if (self.lineRelativeValue != 0) {
                barH = yValue*avgHeight/self.lineRelativeValue;
            }
            CGFloat barY = self.zeroY-barH;
            if (self.lineRelativeValue == 0) {
                barY = self.zeroY;
            }
            CGFloat barX = [self.pointXArray[i] floatValue]-self.barWidth*0.5;
            
            barItemView.frame = CGRectMake(barX, barY, self.barWidth, barH);
            
            // 最后赋值
            NSMutableArray *datasArray = [NSMutableArray array];
            // 单个柱子
            for (int j = 0; j < self.y_axis.count; j++) {
                // 柱子中单个元素的数据，颜色
                SYChartBarItemModel *barItemModel = [[SYChartBarItemModel alloc] init];
                if (j < itemBarDataArray.count) {
                    CGFloat value = [itemBarDataArray[j] doubleValue];
                    barItemModel.value = value;
                    if (realTotalNum>0) {
                        barItemModel.scale = value/realTotalNum;
                    }else{
                        barItemModel.scale = 0;
                    }
                }
                
                SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray[j];
                barItemModel.color = [UIColor colorWithHexString:columnMetaModel.color];
                
                [datasArray addObject:barItemModel];
            }
            barItemView.datasArray = datasArray;
        }
    }

    /// 浮窗标线
    [self setupMarkerViewAndLine];

    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    
    if (self.chartOptions.showSelected) {
        [self defaultLinePlace];
    }
}

@end
