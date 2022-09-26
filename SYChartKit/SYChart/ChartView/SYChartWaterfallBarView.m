//
//  SYChartWaterfallBarView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartWaterfallBarView.h"
#import "SYChartTool.h"
#import "SYChartBarItemView.h"


@interface SYChartWaterfallBarView ()
/// 柱子视图数组
@property (nonatomic, strong) NSMutableArray *barViewArray;
/// 柱子宽度
@property (nonatomic, assign) CGFloat barWidth;

@end

@implementation SYChartWaterfallBarView
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

/// 检查校验数据结构是否有误
-(BOOL)checkChartData{
    BOOL result = [super checkChartData];
    if (!result) {
        return NO;
    }
    // 瀑布图数据特殊处理
    NSMutableArray *yArray = self.chartModel.dataInfo.datas.mutableCopy;
    if (yArray.count>1) {
        [yArray removeObjectAtIndex:0];// 排除X轴数据
        self.y_axis = yArray.firstObject;// y_axis仅有一项
    }
    return YES;
}

/// 绘制图表
- (void)drawGraphViewUI{
    // 获取所有Y轴合计数据值
    NSMutableArray *dataListArray = [NSMutableArray array];
    
    // 获取所有Y轴合计真实数据值(元素为单柱子堆积数据的集合)
    NSMutableArray *realDataListArray = [NSMutableArray array];
    
    // 取出datas元素中最大长度的数据(数组元素最多)
    NSInteger maxBarCount = self.y_axis.count;
    // 瀑布图第一个元素最大为合计数据，其余分布叠加位置(可以看成每个柱子由count-1项堆积而成，仅绘制显示对应区域即可)
    
    // 不断叠加子项
    NSMutableArray *tempAddArray = [NSMutableArray array];
    
    CGFloat objFloat = 0;
    for (int i=0; i<maxBarCount; i++) {
        id obj = self.y_axis[i];
        if ([obj isKindOfClass:[NSNumber class]]) {
            objFloat = [obj doubleValue];
        }else if ([obj isKindOfClass:[NSString class]]){
            objFloat = [obj doubleValue];
        }
        
        if (self.chartModel.chartOptions.limitMinY && objFloat<0) {// 不能为负数
            objFloat = 0;
        }
        
        // 单个柱子所需数据
        NSMutableArray *itemBarDataArray = [NSMutableArray array];
        if (i == 0) {
            [itemBarDataArray addObject:@(objFloat)];
        }else{
            // 叠加子项
            [tempAddArray addObject:@(objFloat)];
            [itemBarDataArray addObjectsFromArray:tempAddArray];
        }
        
        [realDataListArray addObject:itemBarDataArray];
        
        [dataListArray addObject:@(objFloat)];
    }

    // y坐标最大值
    CGFloat maxValue = [SYChartTool getMaxValueWithDataArray:dataListArray];
    // y坐标最小值
    CGFloat minValue = [SYChartTool getMinValueWithDataArray:dataListArray];

    // 是否显示负数 （目前暂不支持）
//    BOOL showMinus = minValue<0?YES:NO;
    
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
        self.chartOptions.topMargin = 20*kScreenScale;
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
            CGFloat realTotalNum = [[itemBarDataArray valueForKeyPath:@"@sum.floatValue"] doubleValue];

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
            for (int j = 0; j < itemBarDataArray.count; j++) {
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
                if (j == itemBarDataArray.count-1) {
                    SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray.lastObject;
                    barItemModel.color = [UIColor colorWithHexString:columnMetaModel.color];
                }else{
                    barItemModel.color = [UIColor clearColor];
                }
                
                [datasArray addObject:barItemModel];
            }
            barItemView.datasArray = datasArray;
            
            
            // 柱子顶部值显示
            SYChartBarItemModel *lastItemModel = datasArray.lastObject;
//            if (lastItemModel.value>0) {
                UILabel *itemValueLabel = [[UILabel alloc] init];
                itemValueLabel.textColor = [UIColor colorWithHexString:@"#222222"];
                itemValueLabel.font = kFontNumberScale(12);
                itemValueLabel.textAlignment = NSTextAlignmentCenter;
                [self addSubview:itemValueLabel];
                
                if (self.chartOptions.barShowInteger) {
                    itemValueLabel.text = [@(lastItemModel.value) handleDoubleFormatDecimalPlace:0 round:YES removeEnd:YES];;
                }else{
                    itemValueLabel.text = [@(lastItemModel.value) handleTwoDecimal];
                }
                
                CGSize valueSize = [SYChartTool sizeWithString:itemValueLabel.text font:itemValueLabel.font maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
                
                CGFloat itemValueX = [self.pointXArray[i] floatValue];
                itemValueLabel.frame = CGRectMake(itemValueX-valueSize.width*0.5, barY-valueSize.height-5*kScreenScale, valueSize.width, valueSize.height);
                if (itemValueLabel.x < self.startLayerX+2*kScreenScale) {
                    itemValueLabel.x = self.startLayerX+2*kScreenScale;
                }else if (itemValueLabel.x+itemValueLabel.width > self.contentW){
                    itemValueLabel.x = self.contentW-itemValueLabel.width-2*kScreenScale;
                }
//            }
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
