//
//  SYChartDoubleAxisLineGraphView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartDoubleAxisLineGraphView.h"
#import "SYChartTool.h"


@interface SYChartDoubleAxisLineGraphView (){
    CGFloat rightZeroY;// 记录右侧Y轴0点的y坐标
}

/// 右侧Y坐标标题
@property (nonatomic, strong) UILabel *rightYTitleLabel;
/// 右侧label宽度
@property (nonatomic, assign) CGFloat rightLabelWidth;

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
@implementation SYChartDoubleAxisLineGraphView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.rightLabelWidth = self.labelWidth;

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

-(UILabel *)rightYTitleLabel{
    if (!_rightYTitleLabel) {
        _rightYTitleLabel = [[UILabel alloc] init];
        _rightYTitleLabel.font = kFontScale(11);
        _rightYTitleLabel.textColor = self.textColor;
        _rightYTitleLabel.textAlignment = NSTextAlignmentRight;
        _rightYTitleLabel.hidden = YES;
    }
    return _rightYTitleLabel;
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
    [self.pointXArray removeAllObjects];

    self.rightLabelWidth = 0;

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

/// 绘制图表
- (void)drawGraphViewUI{
    // 获取所有Y坐标数据值
    NSMutableArray *dataListArray = [NSMutableArray array];
    // 获取所有右侧轴Y坐标数据值
    NSMutableArray *rightDataListArray = [NSMutableArray array];
    
    
    for (int i=0; i<self.chartModel.dataInfo.datas.count; i++) {
        SYChartColumnMetaModel *columnMetaModel = self.chartModel.dataInfo.columnMetas[i];
        if (i>0) {
            NSArray *itemArr = self.chartModel.dataInfo.datas[i];

            if (itemArr.count>0) {
                // 判断是否都是空或--，是：则不绘制曲线
                NSSet *set = [NSSet setWithArray:itemArr];// 数组去重
                if (set.count == 1) {
                    if ([set containsObject:@""] || [set containsObject:@"--"]) {
                        break;
                    }
                }
                
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

                    if (columnMetaModel.isRightAxis) {// 右侧轴
                        // 取出分别插入指定位置
                        if (j < rightDataListArray.count) {
                            NSMutableArray *arr = rightDataListArray[j];
                            [arr addObject:@(maxScale)];
                        }else{
                            NSMutableArray *arr = [NSMutableArray array];
                            [arr addObject:@(maxScale)];
                            [rightDataListArray addObject:arr];
                        }
                    }else{
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
            }
        }else{
            NSMutableArray *arr = [NSMutableArray array];
            if (columnMetaModel.isRightAxis) {// 右侧轴
                [rightDataListArray addObject:arr];
            }else{
                [dataListArray addObject:arr];
            }
        }
    }

    // y坐标最大值
    CGFloat maxValue = [SYChartTool getMaxValueWithDataArray:dataListArray];
    // y坐标最小值
    CGFloat minValue = [SYChartTool getMinValueWithDataArray:dataListArray];
    /// 获取单位
    ChartUnitNum unitNum = [SYChartTool getUnitNumWithMinValue:minValue maxValue:maxValue rowNum:self.chartOptions.lineNum];
    
    if (unitNum.unitNum > 1) {
        CGFloat temMaxValue = maxValue/unitNum.unitNum;
        if (maxValue != temMaxValue*unitNum.unitNum) {
            // 有小数
            CGFloat floatMaxValue = [@(maxValue) floatValue]/unitNum.unitNum;
            maxValue = [SYChartTool rangeMaxWithValueMax:floatMaxValue];
            if (floatMaxValue < 0) {
                maxValue = -maxValue;
            }
        }else{
            maxValue = temMaxValue;
        }
        
        CGFloat temMinValue = minValue/unitNum.unitNum;
        if (minValue != temMinValue*unitNum.unitNum) {
            // 有小数
            CGFloat floatMinValue = [@(minValue) floatValue]/unitNum.unitNum;
            minValue = [SYChartTool rangeMaxWithValueMax:floatMinValue];
            if (floatMinValue < 0) {
                minValue = -minValue;
            }
        }else{
            minValue = temMinValue;
        } 
    }
    
    
    // 右侧y坐标最大值
    CGFloat rightMaxValue = [SYChartTool getMaxValueWithDataArray:rightDataListArray];
    // 右侧y坐标最小值
    CGFloat rightMinValue = [SYChartTool getMinValueWithDataArray:rightDataListArray];
    /// 获取右侧单位
    ChartUnitNum rightUnitNum = [SYChartTool getUnitNumWithMinValue:rightMinValue maxValue:rightMaxValue rowNum:0];
    
    if (rightUnitNum.unitNum > 1) {
        CGFloat rightTemMaxValue = rightMaxValue/rightUnitNum.unitNum;
        if (rightMaxValue != rightTemMaxValue*rightUnitNum.unitNum) {
            // 有小数
            CGFloat floatMaxValue = [@(rightMaxValue) floatValue]/rightUnitNum.unitNum;
            rightMaxValue = [SYChartTool rangeMaxWithValueMax:floatMaxValue];
            if (floatMaxValue < 0) {
                rightMaxValue = -rightMaxValue;
            }
        }else{
            rightMaxValue = rightTemMaxValue;
        }
        
        CGFloat rightTemMinValue = rightMinValue/rightUnitNum.unitNum;
        if (rightMinValue != rightTemMinValue*rightUnitNum.unitNum) {
            // 有小数
            CGFloat floatMinValue = [@(rightMinValue) floatValue]/rightUnitNum.unitNum;
            rightMinValue = [SYChartTool rangeMaxWithValueMax:floatMinValue];
            if (floatMinValue < 0) {
                rightMinValue = -rightMinValue;
            }
        }else{
            rightMinValue = rightTemMinValue;
        }
    }
    
    
    // 转换成图表适合的范围内最大值 并计算最大宽度
    maxValue = [SYChartTool rangeMaxWithValueMax:maxValue];
    
    BOOL showMinMinus = minValue<0?YES:NO;
    CGFloat tempMinValue = [SYChartTool rangeMaxWithValueMax:fabs([@(minValue) floatValue])];
    if (showMinMinus) {
        minValue = -tempMinValue;
    }else{
        minValue = tempMinValue;
    }
    self.maxValue = maxValue;
    self.minValue = minValue;
    
    
    rightMaxValue = [SYChartTool rangeMaxWithValueMax:rightMaxValue];
    BOOL rightShowMinMinus = rightMinValue<0?YES:NO;
    CGFloat rightTempMinValue = [SYChartTool rangeMaxWithValueMax:fabs([@(rightMinValue) floatValue])];
    if (rightShowMinMinus) {
        rightMinValue = -rightTempMinValue;
    }else{
        rightMinValue = rightTempMinValue;
    }

    /// Y轴纵坐标单位
    [self setupYTitleWithChartUnit:unitNum];
    
    /// 右侧Y轴纵坐标单位
    NSString *chartRightYTitle = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chartViewWithModel:rightUnit:)]) {
        chartRightYTitle = [self.delegate chartViewWithModel:self.chartModel rightUnit:rightUnitNum];
    }
    if (!KStringIsEmpty(chartRightYTitle) || (KStringIsEmpty(self.chartOptions.chartRightYTitle) && KStringIsEmpty(rightUnitNum.unit))) {
        
        if (!self.rightYTitleLabel.superview) {
            [self addSubview:self.rightYTitleLabel];
        }
        self.rightYTitleLabel.hidden = NO;
        self.rightYTitleLabel.font = kFontScale(self.chartOptions.textFontSize);

        if (!KStringIsEmpty(chartRightYTitle)) {
            self.rightYTitleLabel.text = chartRightYTitle;
        }else{
            self.rightYTitleLabel.text = [NSString stringWithFormat:@"%@%@", self.chartOptions.chartRightYTitle, rightUnitNum.unit];
        }
        
        self.rightYTitleLabel.frame = CGRectMake(self.width-self.chartOptions.paddingRight-100*kScreenScale, 5, 100*kScreenScale, 17*kScreenScale);// contentRight
        
    }else{
        self.rightYTitleLabel.hidden = YES;
    }
    
    if (self.yTitleLabel.hidden && self.rightYTitleLabel.hidden) {
        self.chartOptions.topMargin = 10*kScreenScale;
    }

    /// 处理横线区间行数和行间差值
    [self handleHorizontalLineRowAndRelativeValue];
    
    /// 右轴数据
    double rightAvgH = 0;
    NSInteger rightBigRow = self.lineRow;
    NSInteger rightSmallRow = 0;
    
    BOOL rightNoData = (rightMaxValue == 0 && rightMinValue == 0);
    if (!rightNoData && self.lineRow>0) {
//        // 右侧获取最大绝对值
//        rightMaxFabsValue = MAX(fabs(rightMaxValue), fabs(rightMinValue));
        if (rightMaxValue>0 && rightMinValue<0) {// 正负均有值时
            CGFloat allRightValue = fabs(rightMaxValue) + fabs(rightMinValue);
            // 预估行间距
            CGFloat tempRightAvgH = allRightValue / self.lineRow;
            // 获取最小绝对值
            CGFloat rightMinFabsValue = MIN(fabs(rightMaxValue), fabs(rightMinValue));
            CGFloat rightMaxFabsValue = MAX(fabs(rightMaxValue), fabs(rightMinValue));
            // 偏小方向划分行数 向上取整
            NSInteger temRightSmallRow = ceilf(rightMinFabsValue / tempRightAvgH);
            // 偏大方向划分行数
            NSInteger temRightBigRow = self.lineRow - temRightSmallRow;
            
            CGFloat rightMinAvgH = 0;
            if (temRightSmallRow > 0) {
                rightMinAvgH = rightMinFabsValue / temRightSmallRow;
            }
            CGFloat rightMaxAvgH = 0;
            if (rightBigRow > 0) {
                rightMaxAvgH = rightMaxFabsValue / temRightBigRow;
            }
            
            rightAvgH = MAX(rightMinAvgH, rightMaxAvgH);
            
            rightBigRow = temRightBigRow;
            rightSmallRow = temRightSmallRow;
            
        }else{
            // 单方向
            CGFloat rightMaxFabsValue = MAX(fabs(rightMaxValue), fabs(rightMinValue));
            rightAvgH = rightMaxFabsValue / self.lineRow;
        }
    }
    
    // 右轴y坐标文本
    NSArray *rightYTextArray = [self getYLabelTextWithMinValue:rightMinValue maxValue:rightMaxValue smallRow:rightSmallRow bigRow:rightBigRow lineRelativeValue:rightAvgH leftY:NO];
    // 右轴y坐标label最大宽度
    CGFloat maxRightLabelWidth = [self getMaxYLabelWidthWithTextArray:rightYTextArray];
    self.rightLabelWidth = maxRightLabelWidth;
    

    self.startLayerX = self.chartOptions.paddingLeft+self.labelWidth+self.chartOptions.yTitleRightSpace;
    self.contentW = self.width - self.chartOptions.paddingLeft - self.chartOptions.paddingRight;
    self.startLayerW = self.contentW-self.startLayerX-self.chartOptions.layerRightMargin-self.rightLabelWidth+10*kScreenScale;// +10的操作暂未清楚
    
    /// 因处理X坐标label的放置方向，需要首先绘制X坐标，
    // 绘制横坐标label
    self.pointXSpace = self.startLayerW;
    NSArray *xDataArray = self.chartModel.dataInfo.datas[0];
    if (xDataArray.count>2) {
        self.pointXSpace = self.startLayerW / (xDataArray.count-1);
    }

    // 画横坐标
    [self creatXLabelWithXDataArray:xDataArray barMargin:0];
        
    /// 创建纵坐标控件和横虚线
    [self creatYLabelAndDashLine];
    
    /// 创建右轴纵坐标
    CGFloat avgHeight = self.contentH / self.lineRow;
    for (int i = 0; i < rightYTextArray.count; i++) {
        // 从下向上布局
        CGFloat dashLineY = self.height-self.chartOptions.bottomMargin-i*avgHeight;
        CGFloat rightX = self.startLayerX+self.startLayerW+self.chartOptions.yTitleRightSpace;

        // 右轴Y坐标label
        UILabel *yRightLabel = [[UILabel alloc] init];
        yRightLabel.font = kFontScale(self.chartOptions.textFontSize);
        yRightLabel.textColor = self.textColor;
        yRightLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:yRightLabel];
        NSString *rightYText = rightYTextArray[i];
        yRightLabel.text = rightYText;
        yRightLabel.frame = CGRectMake(rightX, dashLineY-self.labelHeight*0.5, self.rightLabelWidth, self.labelHeight);

        if (i == self.rightZeroIndex) {
            rightZeroY = dashLineY;
        }
    }
    
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
    for (int i = 0; i < self.y_axis.count; i++) {
        SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray[i];
        
        UIBezierPath *pointPath = self.pointPathArray[i];
        UIBezierPath *fillPath = self.fillPathArray[i];
        CGPoint startPathPoint = [startPathPointArray[i] CGPointValue];

        NSMutableArray *tempListArray = [NSMutableArray array];
        if (columnMetaModel.isRightAxis) {
            [tempListArray addObjectsFromArray:rightDataListArray];
        }else{
            [tempListArray addObjectsFromArray:dataListArray];
        }

        for (int j = 0; j < tempListArray.count; j++) {
            NSMutableArray *dataArray = tempListArray[j];
            if (dataArray.count == 0) {
                break;
            }
            if (j < self.pointXArray.count) {
                CGFloat x = [self.pointXArray[j] floatValue];
                double yValue = 0;
                CGPoint point = CGPointZero;
                
                if (columnMetaModel.isRightAxis) {
                    yValue = [dataArray[0] doubleValue]/rightUnitNum.unitNum;
                    if (self.chartModel.chartOptions.limitMinY && yValue<0) {// 不能为负数
                        yValue = 0;
                    }
                    
                    point = CGPointMake(x, rightZeroY-yValue*avgHeight/rightAvgH);
                    if (rightAvgH == 0) {
                        point = CGPointMake(x, rightZeroY);
                    }
                }else{
                    yValue = [dataArray[i] doubleValue]/unitNum.unitNum;
                    if (self.chartModel.chartOptions.limitMinY && yValue<0) {// 不能为负数
                        yValue = 0;
                    }
                    point = CGPointMake(x, self.zeroY-yValue*avgHeight/self.lineRelativeValue);
                    if (self.lineRelativeValue == 0) {
                        point = CGPointMake(x, self.zeroY);
                    }
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
