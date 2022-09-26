//
//  SYChartScatterView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//
/*
 四象限位置
 ┏━━━━━━┳━━━━━━┓
 ┃  ②  ┃  ①   ┃
 ┣━━━━━━╋━━━━━━┫
 ┃  ④  ┃  ③   ┃
 ┗━━━━━━┻━━━━━━┛
 
 */

#import "SYChartScatterView.h"


@interface SYChartScatterView ()
/// 象限描述单行时的高/宽
@property (nonatomic, assign) CGFloat textMargin;
/// 单象限的边缘边距
@property (nonatomic, assign) CGFloat markerPadding;

/// 横向中点
@property (nonatomic, assign) double xMid;
/// 纵向中点
@property (nonatomic, assign) double yMid;

/// 横虚线宽
@property (nonatomic, assign) CGFloat xlineW;
/// 纵虚线长
@property (nonatomic, assign) CGFloat ylineW;

/// 圆点直径
@property (nonatomic, assign) double circleW;
/// 圆点最小直径
@property (nonatomic, assign) double minCircleW;
/// 圆点最大直径
@property (nonatomic, assign) double maxCircleW;

/// 遮罩层圆角
@property (nonatomic, assign) CGFloat markerCornerRadius;
 
@property (nonatomic, strong) NSMutableArray *dashLineArray;
@property (nonatomic, strong) NSMutableArray *arrowPathArray;
@property (nonatomic, strong) NSMutableArray *arrowLayerArray;
/// 四象限蒙层
@property (nonatomic, strong) NSMutableArray *markerArray;
/// 选中的象限边框
@property (nonatomic, strong) CAShapeLayer *seletedDashLineLayer;
/// 所有点
@property (nonatomic, strong) NSMutableArray *pointLayerArray;
@end
@implementation SYChartScatterView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.dashLineArray = [NSMutableArray array];
        self.arrowPathArray = [NSMutableArray array];
        self.arrowLayerArray = [NSMutableArray array];
        self.markerArray = [NSMutableArray array];
        self.pointLayerArray = [NSMutableArray array];
        
        self.textColor = [UIColor colorWithHexString:@"#787878"];
        self.colorArray = @[@"#FF2D2D", @"#FF992C", @"#2A9AFE", @"#32CCA6"];
        self.dashLineColor = [UIColor colorWithHexString:@"#DDDDDD"];
        self.textMargin = 13*kScreenScale;
        self.markerPadding = 4*kScreenScale;
        
        self.circleW = 10*kScreenScale;
        self.minCircleW = 6*kScreenScale;
        self.maxCircleW = 60*kScreenScale;
        self.markerCornerRadius = 10;
        
        if (self.panGesture) {
            [self removeGestureRecognizer:self.panGesture];
        }
    }
    return self;
}

/// 重置图表
-(void)resetChart{
    [super resetChart];
    
    for (id obj in self.dashLineArray) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }
    for (id obj in self.arrowPathArray) {
        if ([obj isKindOfClass:[UIBezierPath class]]) {
            [obj removeAllPoints];
        }
    }
    for (id obj in self.arrowLayerArray) {
        if ([obj isKindOfClass:[CAShapeLayer class]]) {
            [obj removeFromSuperlayer];
        }
    }
    for (id obj in self.markerArray) {
        if ([obj isKindOfClass:[UIView class]]) {
            [obj removeFromSuperview];
        }
    }
    for (id obj in self.pointLayerArray) {
        if ([obj isKindOfClass:[CAShapeLayer class]]) {
            [obj removeFromSuperlayer];
        }
    }
    [self.dashLineArray removeAllObjects];
    [self.arrowPathArray removeAllObjects];
    [self.arrowLayerArray removeAllObjects];
    [self.markerArray removeAllObjects];
    [self.pointLayerArray removeAllObjects];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

/// 绘制图表
- (void)drawGraphViewUI{
    // 横纵轴中心点
    self.xMid = (self.width-self.chartOptions.paddingLeft-self.chartOptions.paddingRight)*0.5+self.chartOptions.paddingLeft;
    self.yMid = (self.height-self.chartOptions.topMargin-self.chartOptions.bottomMargin)*0.5+self.chartOptions.topMargin;
    
    // 横纵轴虚线长
    self.xlineW = self.width-self.chartOptions.paddingLeft-self.chartOptions.paddingRight-self.textMargin*2;// 线长
    self.ylineW = self.height-self.chartOptions.topMargin-self.chartOptions.bottomMargin-self.textMargin*2;// 线长
     
    // 绘制横纵轴虚线和箭头
    [self creatDashLine];
    // 创建横纵轴标题
    [self creatLineLabel];
    // 创建四象限遮罩层
    [self creatMarkerView];
    // 创建所有点
    [self creatAllPoint];
    for (UIView *v in self.markerArray) {
        [self bringSubviewToFront:v];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    
    // 默认选中象限的
    if (self.chartOptions.showSelected) {
        [self changeDashLineBorderWithIndex:self.chartModel.dataInfo.extra.defaultIndex];
    }
}

/// 创建所有点
-(void)creatAllPoint{
    NSArray *xArray = self.chartModel.dataInfo.datas[0];
    NSArray *yArray = self.chartModel.dataInfo.datas[1];
    if (xArray.count != yArray.count) {
        return;
    }
    
    // 横轴最大值最小值
//    double xMaxValue = [[xArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
//    double xMinValue = [[xArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    NSNumber *xMaxNumber = [xArray valueForKeyPath:@"@max.doubleValue"];
    NSNumber *xMinNumber = [xArray valueForKeyPath:@"@min.doubleValue"];
    double xMaxValue = [xMaxNumber doubleValue];
    double xMinValue = [xMinNumber doubleValue];
    
//    NSArray *temXArray = [xArray.copy sortedArrayUsingSelector:@selector(compare:)];
//    float xMinValue = [numbers[0] floatValue];
//    float xMaxValue = [[numbers lastObject] floatValue];
    
    // 纵轴最大值最小值
//    double yMaxValue = [[yArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
//    double yMinValue = [[yArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    
//    NSArray *temYArray = [yArray.copy sortedArrayUsingSelector:@selector(compare:)];
//    float yMinValue = [numbers[0] floatValue];
//    float yMaxValue = [[numbers lastObject] floatValue];
    NSNumber *yMaxNumber = [yArray valueForKeyPath:@"@max.doubleValue"];
    NSNumber *yMinNumber = [yArray valueForKeyPath:@"@min.doubleValue"];
    double yMaxValue = [yMaxNumber doubleValue];
    double yMinValue = [yMinNumber doubleValue];
    
    double xMedian = self.chartModel.dataInfo.extra.xmedian;
    if (xMedian == -0.01) {// 没有提供中位数时使用平均值
        xMedian = (xMaxValue-xMinValue)/2;
    }
    double yMedian = self.chartModel.dataInfo.extra.ymedian;
    if (yMedian == -0.01) {// 没有提供中位数时使用平均值
        yMedian = (yMaxValue-yMinValue)/2;
    }

    // 计算最大的偏移值，确定另外方向的值，并重新赋值最大或最小值
    double temXMax = xMaxValue-xMedian;// 右侧
    double temXMin = xMedian-xMinValue;// 左侧
    if (fabs(temXMax) != fabs(temXMin)) {
        if (temXMax > temXMin) {
            xMinValue = xMedian-temXMax;
        }else{
            xMaxValue = xMedian+temXMin;
        }
    }
    
    double temYMax = yMaxValue-yMedian;// 上侧
    double temYMin = yMedian-yMinValue;// 下侧
    if (fabs(temYMax) != fabs(temYMin)) {
        if (temYMax > temYMin) {
            yMinValue = yMedian-temYMax;
        }else{
            yMaxValue = yMedian+temYMin;
        }
    }
    
    // 位置换算，需减去遮罩层距离中线间距
    double xAvg = (MAX(temXMax, temXMin))/(self.xlineW*0.5-self.markerPadding);
    double yAvg = (MAX(temYMax, temYMin))/(self.ylineW*0.5-self.markerPadding);
    
    // 气泡图直径换算
    NSArray *diameterValueArray = nil;
    double diameterMinValue = 0;
    double diameterAvg = 0;
    if (self.chartOptions.chartType == SYChartType_Bubble && self.chartModel.dataInfo.datas.count > 2) {
        // 直径最大值最小值
        diameterValueArray = self.chartModel.dataInfo.datas[2];
        if (xArray.count == diameterValueArray.count) {
            double diameterMaxValue = [[diameterValueArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
            diameterMinValue = [[diameterValueArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
            diameterAvg = (diameterMaxValue-diameterMinValue)/(self.maxCircleW-self.minCircleW);
            if (diameterMaxValue == diameterMinValue) {
                diameterAvg = 1;
            }
        }else{
            diameterValueArray = nil;
        }
    }
    
    UIColor *circleColor = [UIColor colorWithHexString:@"#FC3737"];

    for (int i = 0; i < xArray.count; i++) {
//        if (diameterValueArray.count>0) {
//            CGFloat diameterValue = [diameterValueArray[i] floatValue];
//            if (diameterValue == 1) {
//                DVLog(@"");
//            }
//        }
        
        // 圆心X
        double pointX = self.xMid;
        if (xMaxValue == xMinValue) {
//            pointX = self.xMid;
        }else{
            double x = [xArray[i] doubleValue];
            pointX = (x-xMedian)/xAvg+self.xMid;
        }
        
        // 圆心Y
        double pointY = self.yMid;
        if (yMaxValue == yMinValue) {
//            pointY = self.yMid;
        }else{
            double y = [yArray[i] doubleValue];
            pointY = self.yMid-(y-yMedian)/yAvg;
        }
             
        // 圆点直径
        double circleW = self.circleW;
        if (self.chartOptions.chartType == SYChartType_Bubble && diameterValueArray.count > 0) {
            double diameterValue = [diameterValueArray[i] doubleValue];
            circleW = (diameterValue-diameterMinValue)/diameterAvg;
            if (circleW < self.minCircleW) {
                if (circleW == 0 && diameterValueArray.count == 1) {
                    circleW = self.maxCircleW;// 仅有一个点时使用最大圆
                }else{
                    circleW = self.minCircleW;
                }
            }
            if (circleW > self.maxCircleW) {
                circleW = self.maxCircleW;
            }
        }
        
        double overCircle = 0;
//        if (circleW*0.5 < self.markerCornerRadius) {
//            overCircle = self.markerCornerRadius-circleW*0.5;
//        }
        
        // 圆点和边框圆角的半径差值，用于处理圆点超出边框边缘的逻辑
        double otherCircle = circleW*0.5+overCircle;
        
        // 边缘数据校验，将超出Marker的部分贴边放置
        // 首先计算出所处象限
        if (pointX >= self.xMid) {// 右侧
            pointX = pointX+self.markerPadding;
            
            if ((pointX-otherCircle) < (self.xMid+self.markerPadding)) {// 超出左边
                pointX = self.xMid+self.markerPadding+otherCircle;
            }
            if ((pointX+otherCircle) > (self.width-self.chartOptions.paddingRight-self.textMargin)) {// 超出右边
                pointX = self.width-self.chartOptions.paddingRight-self.textMargin-otherCircle;
            }
            
            if (pointY > self.yMid) {// 下侧
                pointY = pointY+self.markerPadding;
                
                // 第三象限
                circleColor = [self getCircleColorWithIndex:3];
                
                if ((pointY-otherCircle) < (self.yMid+self.markerPadding)) {// 超出上侧
                    pointY = self.yMid+self.markerPadding+otherCircle;
                }
                if ((pointY+otherCircle) > self.height-self.chartOptions.bottomMargin-self.textMargin) {// 超出下侧
                    pointY = self.height-self.chartOptions.bottomMargin-self.textMargin-otherCircle;
                }
                
            }else{// 上侧
                // 因自上向下布局Y值，此处无需再处理pointY的markerPadding
                pointY = pointY-self.markerPadding;
                
                // 第一象限
                circleColor = [self getCircleColorWithIndex:1];
                
                if ((pointY-otherCircle) < (self.chartOptions.topMargin+self.textMargin)) {// 超出上侧
                    pointY = self.chartOptions.topMargin+self.textMargin+otherCircle;
                }
                if ((pointY+otherCircle) > (self.yMid-self.markerPadding)) {// 超出下侧
                    pointY = self.yMid-self.markerPadding-otherCircle;
                }
            }
        }else{// 左侧
            pointX = pointX-self.markerPadding;
            
            if ((pointX-otherCircle) < (self.chartOptions.paddingLeft+self.textMargin)) {// 超出左边
                pointX = self.chartOptions.paddingLeft+self.textMargin+otherCircle;
            }
            if ((pointX+otherCircle) > (self.xMid-self.markerPadding)) {// 超出右边
                pointX = self.xMid-self.markerPadding-otherCircle;
            }
            
            if (pointY > self.yMid) {// 下侧
                pointY = pointY+self.markerPadding;
                
                // 第四象限
                circleColor = [self getCircleColorWithIndex:4];
                
                if ((pointY-otherCircle) < (self.yMid+self.markerPadding)) {// 超出上侧
                    pointY = self.yMid+self.markerPadding+otherCircle;
                }
                if ((pointY+otherCircle) > (self.height-self.chartOptions.bottomMargin-self.textMargin)) {// 超出下侧
                    pointY = self.height-self.chartOptions.bottomMargin-self.textMargin-otherCircle;
                }
            }else{// 上侧
                // 因自上向下布局Y值，此处无需再处理pointY的markerPadding
                pointY = pointY-self.markerPadding;
                
                // 第二象限
                circleColor = [self getCircleColorWithIndex:2];
                
                if ((pointY-otherCircle) < (self.chartOptions.topMargin+self.textMargin)) {// 超出上侧
                    pointY = self.chartOptions.topMargin+self.textMargin+otherCircle;
                }
                if ((pointY+otherCircle) > (self.yMid-self.markerPadding)) {// 超出下侧
                    pointY = self.yMid-self.markerPadding-otherCircle;
                }
            }
        }
             
//        // 最小值等于最大值时，圆点处于中心
//        if (xMaxValue == xMinValue && yMaxValue == yMinValue) {
//            pointX = self.xMid;
//            pointY = self.yMid;
//        }
        
        // 绘制圆点
        UIBezierPath *beizPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(pointX-circleW*0.5, pointY-circleW*0.5, circleW, circleW) cornerRadius:circleW*0.5];
        CAShapeLayer *pointLayer = [CAShapeLayer layer];
        pointLayer.path = beizPath.CGPath;
        pointLayer.fillColor = circleColor.CGColor;//填充色
        pointLayer.strokeColor = [UIColor clearColor].CGColor;//边框颜色
        pointLayer.lineCap = kCALineCapRound;//线框类型
        [self.layer addSublayer:pointLayer];
        
        [self.pointLayerArray addObject:pointLayer];
        
//#ifdef DEBUG
//        // 绘制点位xy值
//        NSString *pointText = [NSString stringWithFormat:@"X:%@, Y:%@", xArray[i], yArray[i]];
//        if (diameterValueArray.count > 0 && i < diameterValueArray.count) {
//            pointText = [pointText stringByAppendingFormat:@", Z:%@", diameterValueArray[i]];
//        }
//
//        CGFloat textW = KStringWidth(pointText, 15*kScreenScale, kFontScale(5));
//        UILabel *pointLabel = [[UILabel alloc] init];
//        pointLabel.frame = CGRectMake(pointX-textW*0.5, pointY-15*0.5*kScreenScale, textW, 15*kScreenScale);
//        pointLabel.textColor = [UIColor blueColor];
//        pointLabel.font = kFontScale(5);
//        pointLabel.text = pointText;
//        [self addSubview:pointLabel];
//#endif
    }
}

/// 绘制横纵轴虚线和箭头
-(void)creatDashLine{
    UIImageView *xDashLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.chartOptions.paddingLeft+self.textMargin, self.yMid, self.xlineW, 1)];
    [SYChartTool drawLineOfDashByCAShapeLayer:xDashLine lineLength:5 lineSpacing:2 lineColor:self.dashLineColor];
    [self addSubview:xDashLine];
    
    UIImageView *yDashLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.xMid, self.chartOptions.topMargin+self.textMargin, 1, self.ylineW)];
    [SYChartTool drawHLineOfDashByCAShapeLayer:yDashLine lineLength:5 lineSpacing:2 lineColor:self.dashLineColor];
    [self addSubview:yDashLine];
    
    // 绘制箭头
    UIBezierPath *xArrowPath = [UIBezierPath bezierPath];
    [xArrowPath moveToPoint:CGPointMake(xDashLine.right, xDashLine.centerY-3.5)];
    [xArrowPath addLineToPoint:CGPointMake(xDashLine.right+3, xDashLine.centerY)];
    [xArrowPath addLineToPoint:CGPointMake(xDashLine.right, xDashLine.centerY+3.5)];
    
    CAShapeLayer *xArrowLayer = [CAShapeLayer layer];
    xArrowLayer.lineWidth = 1;
    xArrowLayer.fillColor = [UIColor clearColor].CGColor;
    xArrowLayer.strokeColor = [UIColor colorWithHexString:@"#787878"].CGColor;
    xArrowLayer.path = xArrowPath.CGPath;
    [self.layer addSublayer:xArrowLayer];
    
    UIBezierPath *yArrowPath = [UIBezierPath bezierPath];
    [yArrowPath moveToPoint:CGPointMake(yDashLine.centerX-3.5, yDashLine.top)];
    [yArrowPath addLineToPoint:CGPointMake(yDashLine.centerX, yDashLine.top-3)];
    [yArrowPath addLineToPoint:CGPointMake(yDashLine.centerX+3.5, yDashLine.top)];
    
    CAShapeLayer *yArrowLayer = [CAShapeLayer layer];
    yArrowLayer.lineWidth = 1;
    yArrowLayer.fillColor = [UIColor clearColor].CGColor;
    yArrowLayer.strokeColor = [UIColor colorWithHexString:@"#787878"].CGColor;
    yArrowLayer.path = yArrowPath.CGPath;
    [self.layer addSublayer:yArrowLayer];
    
    [self.dashLineArray addObject:xDashLine];
    [self.dashLineArray addObject:yDashLine];
    [self.arrowPathArray addObject:xArrowPath];
    [self.arrowLayerArray addObject:xArrowLayer];
    [self.arrowPathArray addObject:yArrowPath];
    [self.arrowLayerArray addObject:yArrowLayer];
}
/// 创建横纵轴标题
-(void)creatLineLabel{
    NSArray *quadrantArray = self.chartModel.dataInfo.extra.quadrantArray;
    if (quadrantArray.count >= 4) {
        CGFloat space = 10;// 标题相对箭头的间距
        
        UILabel *rightLabel = [self lineTitleLabelWithText:quadrantArray[0]];
        [self addSubview:rightLabel];
        CGFloat rightH = KStringHeight(rightLabel.text, self.textMargin, rightLabel.font);
        rightLabel.frame = CGRectMake(self.width-self.chartOptions.paddingRight-self.textMargin+space, self.yMid-rightH*0.5, self.textMargin, rightH);
                
        UILabel *topLabel = [self lineTitleLabelWithText:quadrantArray[1]];
        [self addSubview:topLabel];
        CGFloat topW = KStringWidth(topLabel.text, self.textMargin, topLabel.font);
        topLabel.frame = CGRectMake(self.xMid-topW*0.5, self.chartOptions.topMargin-space, topW, self.textMargin);
        
        UILabel *bottomLabel = [self lineTitleLabelWithText:quadrantArray[2]];
        [self addSubview:bottomLabel];
        CGFloat bottomW = KStringWidth(bottomLabel.text, self.textMargin, bottomLabel.font);
        bottomLabel.frame = CGRectMake(self.xMid-bottomW*0.5, self.height-self.chartOptions.bottomMargin-self.textMargin+space, bottomW, self.textMargin);
        
        UILabel *leftLabel = [self lineTitleLabelWithText:quadrantArray[3]];
        [self addSubview:leftLabel];
        CGFloat leftH = KStringHeight(leftLabel.text, self.textMargin, leftLabel.font);
        leftLabel.frame = CGRectMake(self.chartOptions.paddingLeft-space, self.yMid-leftH*0.5, self.textMargin, leftH);
    }
}
-(UILabel *)lineTitleLabelWithText:(NSString *)text{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kFontScale(13);
    titleLabel.textColor = self.textColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.text = text;
    titleLabel.accessibilityIdentifier = @"ScatterLineLabel";
    
    return titleLabel;
}
/// 创建四象限遮罩层
-(void)creatMarkerView{
    CGFloat leftW = self.xMid-self.markerPadding-self.textMargin-self.chartOptions.paddingLeft;
    CGFloat rightW = self.width-self.xMid-self.markerPadding-self.textMargin-self.chartOptions.paddingRight;
    
    CGFloat topH = self.yMid-self.chartOptions.topMargin-self.textMargin-self.markerPadding;
    CGFloat bottomH = self.height-self.yMid-self.chartOptions.bottomMargin-self.textMargin-self.markerPadding;

    UIControl *markerControl1 = [self itemMarkerViewWithIndex:1 size:CGSizeMake(rightW, topH)];
    markerControl1.left = self.xMid+self.markerPadding;
    markerControl1.top = self.yMid-self.markerPadding-markerControl1.height;
    [self addSubview:markerControl1];
    
    UIControl *markerControl2 = [self itemMarkerViewWithIndex:2 size:CGSizeMake(leftW, topH)];
    markerControl2.left = self.xMid-self.markerPadding-markerControl2.width;
    markerControl2.top = self.yMid-self.markerPadding-markerControl2.height;
    [self addSubview:markerControl2];
    
    UIControl *markerControl3 = [self itemMarkerViewWithIndex:3 size:CGSizeMake(rightW, bottomH)];
    markerControl3.left = self.xMid+self.markerPadding;
    markerControl3.top = self.yMid+self.markerPadding;
    [self addSubview:markerControl3];
    
    UIControl *markerControl4= [self itemMarkerViewWithIndex:4 size:CGSizeMake(leftW, bottomH)];
    markerControl4.left = self.xMid-self.markerPadding-markerControl4.width;
    markerControl4.top = self.yMid+self.markerPadding;
    [self addSubview:markerControl4];
    
    if (markerControl1) {
        [self.markerArray addObject:markerControl1];
    }
    
    if (markerControl2) {
        [self.markerArray addObject:markerControl2];
    }
    if (markerControl3) {
        [self.markerArray addObject:markerControl3];
    }
    if (markerControl4) {
        [self.markerArray addObject:markerControl4];
    }
    
    [self creatDashLineBorderWithSize:markerControl1.size];
}
-(UIControl *)itemMarkerViewWithIndex:(NSInteger)index size:(CGSize)size{
    SYChartScatterExtraModel *itemModel = nil;
    NSArray *scatterInfo = self.chartModel.dataInfo.extra.scatterInfo;
    if (scatterInfo.count > 0) {
        for (SYChartScatterExtraModel *temModel in scatterInfo) {
            if (temModel.index == index) {
                itemModel = temModel;
            }
        }
    }
//    if (!itemModel) {
//        return nil;
//    }
    
    UIControl *markerControl = [[UIControl alloc] init];
    markerControl.layer.cornerRadius = self.markerCornerRadius;
    markerControl.layer.masksToBounds = YES;
    markerControl.frame = CGRectMake(0, 0, size.width, size.height);
    markerControl.tag = 2220+index;
    [markerControl addTarget:self action:@selector(clickMarkerControl:) forControlEvents:UIControlEventTouchUpInside];
    
    // 绘制渐变色
    NSArray *colorArr = @[(id)[UIColor colorWithHexString:@"#000000" alpha:0].CGColor, (id)[UIColor colorWithHexString:@"#000000" alpha:0.4].CGColor];
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];

    CGFloat gradientH = 45*kScreenScale;
    if (gradientH > markerControl.height*0.5) {
        gradientH = markerControl.height*0.5;
    }
    gradientLayer1.frame = CGRectMake(0, markerControl.height-gradientH, markerControl.width, gradientH);
    gradientLayer1.colors = colorArr;
    gradientLayer1.startPoint = CGPointMake(0.5, 0);
    gradientLayer1.endPoint = CGPointMake(0.5, 1);
    gradientLayer1.locations = @[@(0), @(1.0f)];
    [markerControl.layer addSublayer:gradientLayer1];
//    gradientLayer1.mask = markerControl.layer;
    
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = [UIImage imageNamed:@"Subject_Food_scatterArrow"];
    arrowImageView.frame = CGRectMake(markerControl.width-12*kScreenScale-11*kScreenScale, markerControl.height-12*kScreenScale-11*kScreenScale, 12*kScreenScale, 12*kScreenScale);
    [markerControl addSubview:arrowImageView];
    
    if (!KStringIsEmpty(itemModel.name)) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.font = kFontBoldScale(14);
        textLabel.textColor = [UIColor whiteColor];
        [markerControl addSubview:textLabel];
        textLabel.frame = CGRectMake(17*kScreenScale, markerControl.height-7*kScreenScale-20*kScreenScale, arrowImageView.left-17*kScreenScale, 20*kScreenScale);
        textLabel.text = itemModel.name;
    }
    
    return markerControl;
}
/// 创建选中时虚线边框
-(void)creatDashLineBorderWithSize:(CGSize)size{
    [self.seletedDashLineLayer removeFromSuperlayer];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    [shapeLayer setBounds:size];
//    [shapeLayer setPosition:CGPointMake(size.width / 2, size.height)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色
    [shapeLayer setStrokeColor:[UIColor colorWithHexString:@"#FF2D2D"].CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil]];
    
    self.seletedDashLineLayer = shapeLayer;
}
/// 象限点击事件
-(void)clickMarkerControl:(UIControl *)sender{
    NSInteger index = sender.tag-2220;
    
    [self changeDashLineBorderWithIndex:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chartViewDelegateWithSelectedObject:)]) {
        NSArray *scatterInfo = self.chartModel.dataInfo.extra.scatterInfo;
        if (scatterInfo.count > 0 && index>0 && index-1 < scatterInfo.count) {
            SYChartScatterExtraModel *temModel = scatterInfo[index-1];
            [self.delegate chartViewDelegateWithSelectedObject:temModel.name];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chartViewDelegateWithSelectedIndex:)]) {
        [self.delegate chartViewDelegateWithSelectedIndex:index];
    }

    if (self.selectedIndexBlock) {
        self.selectedIndexBlock(index);
    }
}
/// 设置选中位置
-(void)changeSelectedWithIndex:(NSInteger)index{
//    [self changeDashLineBorderWithIndex:index+1];
}
/// 设置选中项
-(void)changeSelectedWithObject:(id)obj{
    NSArray *scatterInfo = self.chartModel.dataInfo.extra.scatterInfo;
    if ([obj isKindOfClass:[NSString class]] && !KStringIsEmpty(obj) && scatterInfo.count > 0) {
        NSInteger index = -1;
        
        for (int i=0; i<scatterInfo.count; i++) {
            SYChartScatterExtraModel *temModel = scatterInfo[i];
            if ([temModel.name containsString:obj]) {
                index = i;
            }
        }
        if (index>=0) {
            [self changeDashLineBorderWithIndex:index+1];
        }
    }
}
/// 设置选中象限虚线位置
-(void)changeDashLineBorderWithIndex:(NSInteger)index{
    if (index>0 && index-1 < self.markerArray.count) {
        UIControl *markerControl = self.markerArray[index-1];
        
        [self creatDashLineBorderWithSize:markerControl.size];
        
        // 设置路径
        self.seletedDashLineLayer.path = [UIBezierPath bezierPathWithRoundedRect:markerControl.bounds cornerRadius:self.markerCornerRadius].CGPath;
        self.seletedDashLineLayer.frame = markerControl.bounds;
        
        [markerControl.layer addSublayer:self.seletedDashLineLayer];
    }
}
/// 根据象限获取圆点颜色（index为象限）
-(UIColor *)getCircleColorWithIndex:(NSInteger)index{
    CGFloat alpha = 1;
    if (self.chartOptions.chartType == SYChartType_Bubble && self.chartModel.dataInfo.datas.count > 2) {
        alpha = 0.5;
    }
    UIColor *circleColor = [UIColor colorWithHexString:@"#FC3737" alpha:alpha];
    if (index > 0 && index-1 < self.colorArray.count) {
        NSString *color = self.colorArray[index-1];
        if (!KStringIsEmpty(color)) {
            circleColor = [UIColor colorWithHexString:color alpha:alpha];
        }
    }
    
    return circleColor;
}

@end
