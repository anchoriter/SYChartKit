//
//  SYChartLineGraphView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartLineGraphView.h"
#import "SYChartTool.h"


@interface SYChartLineGraphView ()
/// 线绘制图层
@property (nonatomic, strong) NSMutableArray *lineLayerArray;
/// 线绘制路径
@property (nonatomic, strong) NSMutableArray *pointPathArray;
/// 线填充路径
@property (nonatomic, strong) NSMutableArray *fillPathArray;
/// 线结束点
@property (nonatomic, strong) NSMutableArray *endPointArray;
/// 线填充图层
@property (nonatomic, strong) NSMutableArray *gradientLayerArray;
/// 线动画图层
@property (nonatomic, strong) NSMutableArray *progressLayerArray;

@property (nonatomic, strong) NSMutableArray *linePathLayerArray;

@end
@implementation SYChartLineGraphView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineLayerArray = [NSMutableArray array];
        self.pointPathArray = [NSMutableArray array];
        self.fillPathArray = [NSMutableArray array];
        self.endPointArray = [NSMutableArray array];
        self.gradientLayerArray = [NSMutableArray array];
        self.progressLayerArray = [NSMutableArray array];
        self.linePathLayerArray = [NSMutableArray array];
    }
    return self;
}

/// 重置图表
-(void)resetChart{
    [super resetChart];
    
    for (id pointValue in self.endPointArray) {
        if ([pointValue isKindOfClass:[NSValue class]]) {
            CGPoint endPoint = [pointValue CGPointValue];
            endPoint = CGPointZero;
        }
    }
    for (id pointPath in self.pointPathArray) {
        if ([pointPath isKindOfClass:[UIBezierPath class]]) {
            [pointPath removeAllPoints];
        }
    }
    for (id fillPath in self.fillPathArray) {
        if ([fillPath isKindOfClass:[UIBezierPath class]]) {
            [fillPath removeAllPoints];
        }
    }
    for (id lineLayer in self.lineLayerArray) {
        if ([lineLayer isKindOfClass:[CAShapeLayer class]]) {
            [lineLayer removeFromSuperlayer];
        }
    }
    for (id gradientLayer in self.gradientLayerArray) {
        if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
            [gradientLayer removeFromSuperlayer];
        }
    }
    for (id progressLayer in self.progressLayerArray) {
        if ([progressLayer isKindOfClass:[CAShapeLayer class]]) {
            [progressLayer removeFromSuperlayer];
        }
    }
    for (id progressLayer in self.linePathLayerArray) {
        if ([progressLayer isKindOfClass:[CAShapeLayer class]]) {
            [progressLayer removeFromSuperlayer];
        }
    }

    [self.lineLayerArray removeAllObjects];
    [self.pointPathArray removeAllObjects];
    [self.fillPathArray removeAllObjects];
    [self.endPointArray removeAllObjects];
    [self.gradientLayerArray removeAllObjects];
    [self.progressLayerArray removeAllObjects];
    [self.dotPointArray removeAllObjects];

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}



/// 绘制图表
- (void)drawGraphViewUI{
//    // 存储Y轴坐标文字，计算最大label显示宽度
//    NSMutableArray *valueStrArray = [NSMutableArray array];

    // 获取所有Y坐标数据值
    NSMutableArray *dataListArray = [NSMutableArray array];
    for (int i=0; i<self.chartModel.dataInfo.datas.count; i++) {
        if (i>0) {
            NSArray *itemArr = self.chartModel.dataInfo.datas[i];
            if (itemArr.count>0) {
                for (int j=0; j<itemArr.count; j++) {
                    id obj = itemArr[j];

                    CGFloat objFloat = 0;
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        objFloat = [obj doubleValue];
                    }else if ([obj isKindOfClass:[NSString class]]){
                        objFloat = [obj doubleValue];
                    }

                    if (self.chartModel.chartOptions.limitMinY && objFloat<0) {// 不能为负数
                        objFloat = 0;
                    }
                    CGFloat maxScale = objFloat;
                    
                    // 取出分别插入指定位置
                    if (j < dataListArray.count) {
                        NSMutableArray *arr = dataListArray[j];
                        [arr addObject:@(maxScale)];
                    }else{
                        NSMutableArray *arr = [NSMutableArray array];
                        [arr addObject:@(maxScale)];
                        [dataListArray addObject:arr];
                    }
                }
            }
        }else{
            NSMutableArray *arr = [NSMutableArray array];
            [dataListArray addObject:arr];
        }
    }

    // y坐标最大值
    CGFloat maxValue = [SYChartTool getMaxValueWithDataArray:dataListArray];

    // y坐标最小值
    CGFloat minValue = [SYChartTool getMinValueWithDataArray:dataListArray];
    
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
    // 计算横坐标点间距
    self.pointXSpace = self.startLayerW;
    NSArray *xDataArray = self.chartModel.dataInfo.datas[0];
    if (xDataArray.count>2) {
        self.pointXSpace = self.startLayerW / (xDataArray.count-1);
    }

    // 画横坐标
    [self creatXLabelWithXDataArray:xDataArray barMargin:0];

    /// 创建纵坐标控件和横虚线
    [self creatYLabelAndDashLine];
    
    // 空数据情况，y坐标在最下方
    if (maxValue == 0 && minValue == 0) {
        self.zeroY = self.height-self.chartOptions.bottomMargin;
    }

    /// 创建所需线和图层
    NSMutableArray *startPathPointArray = [NSMutableArray array];
    for (int i = 0; i < self.y_axis.count; i++) {
        UIBezierPath *pointPath = [UIBezierPath bezierPath];
        [self.pointPathArray addObject:pointPath];

        UIBezierPath *fillPath = [UIBezierPath bezierPath];
        [fillPath moveToPoint:CGPointMake(self.startLayerX, self.zeroY)];
        [self.fillPathArray addObject:fillPath];

        [self.endPointArray addObject:[NSValue valueWithCGPoint:CGPointZero]];

        [startPathPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(self.startLayerX, self.zeroY)]];
    }

    // 坐标点
    CGFloat avgHeight = self.contentH / self.lineRow;
    for (int i = 0; i < self.y_axis.count; i++) {
        SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray[i];
        
        UIBezierPath *pointPath = self.pointPathArray[i];
        UIBezierPath *fillPath = self.fillPathArray[i];
        CGPoint startPathPoint = [startPathPointArray[i] CGPointValue];

        NSMutableArray *tempListArray = [NSMutableArray array];
        [tempListArray addObjectsFromArray:dataListArray];

        for (int j = 0; j < tempListArray.count; j++) {
            NSMutableArray *dataArray = tempListArray[j];
            if (dataArray.count == 0) {
                break;
            }
            if (j < self.pointXArray.count) {
                CGFloat x = [self.pointXArray[j] floatValue];
                
                double yValue = [dataArray[i] doubleValue]/unitNum.unitNum;
                if (self.chartModel.chartOptions.limitMinY && yValue<0) {// 不能为负数
                    yValue = 0;
                }
                CGPoint point = CGPointMake(x, self.zeroY-yValue*avgHeight/self.lineRelativeValue);
                if (self.lineRelativeValue == 0) {
                    point = CGPointMake(x, self.zeroY);
                }
                
                if (columnMetaModel.showDot) {
                    UIImageView *dotView = [[UIImageView alloc] init];
                    dotView.image = [SYChartTool imageChangeColor:[UIColor colorWithHexString:columnMetaModel.color] image:[UIImage imageNamed:@"red_point"]];
                    [self addSubview:dotView];
                    [self.dotViewArray addObject:dotView];
                    dotView.frame = CGRectMake(x-5, point.y-5, 10, 10);
                }
                if (columnMetaModel.showDotLine) {
                    CAShapeLayer *dotLineLayer = [SYChartTool drawDottedLineWithBeginPoint:CGPointMake(x, self.zeroY) withEndPoint:point color:columnMetaModel.color superLayer:self.layer];
                    if (dotLineLayer) {
                        [self.linePathLayerArray addObject:dotLineLayer];
                    }
                }

                CGPoint center = CGPointMake((j * self.pointXSpace  + self.startLayerX), point.y);
                if (j == 0) {
                    [pointPath moveToPoint:point];
                } else {
                    if (columnMetaModel.showType == SYChartShowType_Curve) {
                        // 折线
                        [pointPath addLineToPoint:point];
                    }else{
                        // 曲线
                        CGPoint midPoint = [SYChartTool midPointForPointsWithP1:startPathPoint p2:center];
                        [pointPath addQuadCurveToPoint:midPoint controlPoint:[SYChartTool controlPointForPointsWithP1:midPoint p2:startPathPoint]];
                        [pointPath addQuadCurveToPoint:center controlPoint:[SYChartTool controlPointForPointsWithP1:midPoint p2:center]];
                    }
                }
                
                if (columnMetaModel.showType == SYChartShowType_Curve) {
                    // 折线
                    [fillPath addLineToPoint:point];
                }else{
                    // 曲线
                    CGPoint midPoint = [SYChartTool midPointForPointsWithP1:startPathPoint p2:center];
                    [fillPath addQuadCurveToPoint:midPoint controlPoint:[SYChartTool controlPointForPointsWithP1:midPoint p2:startPathPoint]];
                    [fillPath addQuadCurveToPoint:center controlPoint:[SYChartTool controlPointForPointsWithP1:midPoint p2:center]];
                }
                
                startPathPoint = center;

                if (j < self.dotPointArray.count) {
                    NSMutableArray *dotArr = self.dotPointArray[j];
                    [dotArr addObject:[NSValue valueWithCGPoint:center]];
                }

                if (i < self.endPointArray.count) {
                    [self.endPointArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:point]];
                }
            }
        }
    }
    
    /// 浮窗标线
    [self setupMarkerViewAndLine];

    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    for (id lineLayer in self.lineLayerArray) {
        if ([lineLayer isKindOfClass:[CAShapeLayer class]]) {
            [lineLayer removeFromSuperlayer];
        }
    }
    for (id gradientLayer in self.gradientLayerArray) {
        if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
            [gradientLayer removeFromSuperlayer];
        }
    }
    for (id progressLayer in self.progressLayerArray) {
        if ([progressLayer isKindOfClass:[CAShapeLayer class]]) {
            [progressLayer removeFromSuperlayer];
        }
    }
    [self.lineLayerArray removeAllObjects];
    [self.gradientLayerArray removeAllObjects];
    [self.progressLayerArray removeAllObjects];
    
    NSMutableArray *tempArray = self.chartModel.dataInfo.datas.mutableCopy;
    if (tempArray.count>0) {
        // 排除X轴数据
        [tempArray removeObjectAtIndex:0];
    }
    
    NSArray *y_axis = tempArray.copy;
    
    if (self.pointPathArray.count == 0 || y_axis.count != self.pointPathArray.count) {
        return;
    }
  
    for (int i = 0; i < y_axis.count; i++) {
        UIBezierPath *pointPath = self.pointPathArray[i];
        NSString *color = self.colorArray[i%self.colorArray.count];
        
        if (i+1 < self.chartModel.dataInfo.columnMetas.count) {
            SYChartColumnMetaModel *columnMetaModel = self.chartModel.dataInfo.columnMetas[i+1];
            color = columnMetaModel.color;
        }

        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        [SYChartTool drawLineWithPath:pointPath lineColor:[UIColor colorWithHexString:color] lineLayer:lineLayer superLayer:self.layer];
        [self.lineLayerArray addObject:lineLayer];

        // 面积填充色
        SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray[i];
        if (columnMetaModel.showAreaLayer) {
            UIBezierPath *fillPath = self.fillPathArray[i];
            CGPoint endPoint = [self.endPointArray[i] CGPointValue];
            [fillPath addLineToPoint:CGPointMake(endPoint.x, self.zeroY)];
            [fillPath addLineToPoint:CGPointMake(self.startLayerX, self.zeroY)];

            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            CAShapeLayer *progressLayer = [CAShapeLayer layer];
            [SYChartTool drawLinearGradientWithPath:fillPath gradientLayer:gradientLayer progressLayer:progressLayer color:color size:CGSizeMake(self.contentW, self.height) superLayer:self.layer];

            [self.gradientLayerArray addObject:gradientLayer];
            [self.progressLayerArray addObject:progressLayer];
        }
    }
    
    if (self.chartOptions.showSelected) {
        [self defaultLinePlace];
    }
}

@end
