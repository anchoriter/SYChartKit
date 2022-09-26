//
//  SYChartCommentView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartCommentView.h"

@interface SYChartCommentView (){
    //触摸开始触碰到的点
    CGPoint touchBeginPoint;
}

@end
@implementation SYChartCommentView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.lineRow = 5;
        self.labelWidth = 24*kScreenScale;
        self.labelHeight = 14*kScreenScale;
        
        self.colorArray = @[@"#FC3737", @"#47BDB9", @"#FFB278"];
        self.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
        self.dashLineColor = [UIColor colorWithHexString:@"#E9E9E9"];
        
        // 处理滑动事件touchesMoved和pagecontrol的scrollView事件冲突
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paned:)];
        panGesture.enabled = NO;
        panGesture.cancelsTouchesInView = FALSE;
        [self addGestureRecognizer:panGesture];
        self.panGesture = panGesture;
    }
    return self;
}
//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
//        CGPoint tempPoint = [gestureRecognizer locationInView:self];
//        if(tempPoint.y < 0){
//            return YES;
//        }
//    }
//    return NO;
//}
/// 滑动手势空实现
- (void)paned:(UIPanGestureRecognizer *)pan{
//    DVLog(@"滑动手势空实现");
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ ///开始拖动
            touchBeginPoint = [pan locationInView:self];//起始点
        }break;
        case UIGestureRecognizerStateChanged:{  ///拖动中
            if(CGPointEqualToPoint(touchBeginPoint, CGPointZero)){
                break;
            }
            
            CGPoint tempPoint = [pan locationInView:self];
//            DVLog(@"滑动手势空实现===%@", NSStringFromCGPoint(tempPoint));
            if(tempPoint.y < 0){
                pan.enabled = NO;
            }
            if(tempPoint.y > self.height){
                pan.enabled = NO;
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{ ///拖动结束
            if(CGPointEqualToPoint(touchBeginPoint, CGPointZero)){
                break;
            }
            touchBeginPoint = CGPointZero;
        }
            break;
        default:
            break;
    }
    
}


/// 绑定数据
-(void)bindChartViewModel:(SYChartBaseModel *)chartModel{
    if (chartModel && self.chartModel != chartModel) {
        self.chartModel = chartModel;
        
        self.chartOptions = chartModel.chartOptions;
        [self reloadChartView];
    }
}
/// 刷新图表
-(void)reloadChartView{
    [self resetChart];
    
    if (![self checkChartData]) {
        return;
    }
    
    [self hiddenMarkerLine];
    
    [self drawGraphViewUI];
}

/// 重置图表
-(void)resetChart{
    self.columnMetaArray = nil;
    self.y_axis = nil;
    self.lineRelativeValue = 0;
    self.yTextArray = nil;
    
    self.contentW = 0;
    self.contentH = 0;
    self.pointXSpace = 0;
    
    self.zeroY = self.height-self.chartOptions.bottomMargin;;
    self.labelWidth = 0;
    self.labelHeight = 0;
    self.startLayerX = 0;
    self.startLayerW = 0;
    
    self.startLayerX = self.chartOptions.paddingLeft+self.labelWidth+self.chartOptions.yTitleRightSpace;
    
    if (self.dotViewArray.count>0) {
        for (UIView *v in self.dotViewArray) {
            [v removeFromSuperview];
        }
        [self.dotViewArray removeAllObjects];
    }
    if (self.markerDotArray.count>0) {
        for (UIView *v in self.markerDotArray) {
            [v removeFromSuperview];
        }
        [self.markerDotArray removeAllObjects];
    }
}

/// 隐藏指示器竖线
-(void)hiddenMarkerLine{
    self.markerRedLine.hidden = YES;
    self.markerView.hidden = YES;
    if (self.markerDotArray.count>0) {
        for (UIView *v in self.markerDotArray) {
            [v removeFromSuperview];
        }
        [self.markerDotArray removeAllObjects];
    }
}


/// 检查校验数据结构是否有误
-(BOOL)checkChartData{
    // 数据长度异常校验
    if (self.chartModel.dataInfo.columnMetas.count != self.chartModel.dataInfo.datas.count) {
        return NO;
    }
    
    if (self.chartModel.dataInfo.columnMetas.count < 2) {
        return NO;
    }
    
    if (self.chartModel.dataInfo.datas.count < 2) {
        return NO;
    }
    
    NSMutableArray *colorArr = [NSMutableArray array];
    for (int i=0; i<self.chartModel.dataInfo.columnMetas.count; i++) {
        SYChartColumnMetaModel *columnMetaModel = self.chartModel.dataInfo.columnMetas[i];
        if (!KStringIsEmpty(columnMetaModel.color)) {
            if (i == 0) {// 横纵坐标文案颜色
                self.textColor = [UIColor colorWithHexString:columnMetaModel.color];
            }else{// 线颜色
                [colorArr addObject:columnMetaModel.color];
            }
        }

        if (columnMetaModel.index < self.chartModel.dataInfo.datas.count) {
            NSArray *itemArr = self.chartModel.dataInfo.datas[columnMetaModel.index];
            if (itemArr.count == 0) {
                return NO;
            }
        }
    }
    
    if (colorArr.count>0) {
        self.colorArray = colorArr.copy;
    }
    
    NSMutableArray *columnMeta = self.chartModel.dataInfo.columnMetas.mutableCopy;
    if (columnMeta.count>1) {
        [columnMeta removeObjectAtIndex:0];// 排除X轴数据
        self.columnMetaArray = columnMeta.copy;
    }

    NSMutableArray *yArray = self.chartModel.dataInfo.datas.mutableCopy;
    if (yArray.count>1) {
        [yArray removeObjectAtIndex:0];// 排除X轴数据
        self.y_axis = yArray.copy;
    }
    
    return YES;
}

/// 绘制图表
- (void)drawGraphViewUI{
    
}

/// 配置纵轴标题
-(void)setupYTitleWithChartUnit:(ChartUnitNum)chartUnit{
    /// Y轴纵坐标单位
    NSString *chartYTitle = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chartViewWithModel:unit:)]) {
        chartYTitle = [self.delegate chartViewWithModel:self.chartModel unit:chartUnit];
    }
    if (!KStringIsEmpty(chartYTitle) || (!KStringIsEmpty(self.chartOptions.chartYTitle) && !KStringIsEmpty(chartUnit.unit))) {
        
        if (!self.yTitleLabel.superview) {
            [self addSubview:self.yTitleLabel];
        }
        self.yTitleLabel.hidden = NO;
        self.yTitleLabel.font = kFontScale(self.chartOptions.textFontSize);

        if (!KStringIsEmpty(chartYTitle)) {
            self.yTitleLabel.text = chartYTitle;
        }else{
            self.yTitleLabel.text = [NSString stringWithFormat:@"%@%@", self.chartOptions.chartYTitle, chartUnit.unit];
        }
        
        self.yTitleLabel.frame = CGRectMake(self.chartOptions.paddingLeft, 8*kScreenScale, 100*kScreenScale, 17*kScreenScale);
        
    }else{
        self.yTitleLabel.hidden = YES;
    }
}

/// 配置浮窗和标线
-(void)setupMarkerViewAndLine{
    /// 浮窗虚线
    if (self.markerRedLine.superview) {
        [self.markerRedLine removeFromSuperview];
    }
    if (self.chartOptions.showMarkLine) {
        [self addSubview:self.markerRedLine];
        
        self.markerRedLine.frame = CGRectMake(0, self.chartOptions.topMargin, 1, self.contentH);
        [SYChartTool drawHLineOfDashByCAShapeLayer:self.markerRedLine lineLength:2 lineSpacing:2 lineColor:[UIColor colorWithHexString:@"#FC3737"]];
    }
    
    if (self.chartOptions.showMarkView || self.chartOptions.showTopDateView) {
        if (!self.markerView.superview) {
            [self addSubview:self.markerView];
        }
    }
}

# pragma mark - 触摸事件
- (void)touchPoint:(CGPoint)point {
    [self calculateLinePlaceWithPoint:point];
 
    //开始触摸
    self.gestureStartPoint = point;
    self.panGesture.enabled = YES;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    self.isMoveing = NO;

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];

    [self touchPoint:point];
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isMoveing = YES;

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch previousLocationInView:touch.view];
    [self calculateLinePlaceWithPoint:point];

    CGPoint currentPosition = [touch locationInView:touch.view];
    CGFloat deltaX = (self.gestureStartPoint.x - currentPosition.x);
    CGFloat deltaY = self.gestureStartPoint.y - currentPosition.y;

    if(fabs(deltaY) > fabs(deltaX)){//上下滑动
        self.panGesture.enabled = NO;

    }else if(fabs(deltaX) > fabs(deltaY)){//左右滑动
        self.panGesture.enabled = YES;
    }
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.isMoveing = NO;

    self.panGesture.enabled = NO;
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.isMoveing = NO;

    self.panGesture.enabled = NO;
}
- (void)calculateLinePlaceWithPoint:(CGPoint)point {
    if (self.chartOptions.autoHiddenMarkView) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenMarkerLine) object:nil];
    }
    
    if (self.pointXArray.count==0) {
        [self hiddenMarkerLine];
        return;
    }

    CGFloat x = point.x;
    CGFloat y = point.y;

    // 超出范围
    if (y > (self.height - self.chartOptions.bottomMargin) || y < self.chartOptions.topMargin || x > self.contentW || x < self.startLayerX) {
//        [self hiddenMarkerLine];
        return;
    }

    // 计算点击点 落在X轴哪个区间 更靠近哪一边，就取哪一边
    NSUInteger index = 0;
    if (self.pointXSpace > 0) {
        double diff = fabs(((x-self.startLayerX) / self.pointXSpace) - floorf((x-self.startLayerX)/self.pointXSpace));
        index = floorf((x-self.startLayerX) / self.pointXSpace) + (diff > 0.5 ? 1 : 0);
    }

    CGFloat maxDotY = 0;
    if (index<self.pointXArray.count) {
        self.markerRedLine.hidden = NO;
        CGFloat lineX = [self.pointXArray[index] floatValue];
        self.markerRedLine.x = lineX;

        if (index<self.dotPointArray.count) {
            if (self.markerDotArray.count>0) {
                for (UIView *v in self.markerDotArray) {
                    [v removeFromSuperview];
                }
                [self.markerDotArray removeAllObjects];
            }

            NSMutableArray *arr = self.dotPointArray[index];
            for (int i=0; i<arr.count; i++) {
                CGPoint point = [arr[i] CGPointValue];
                UIImageView *dotView = [[UIImageView alloc] init];

                SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray[i];
                dotView.image = [SYChartTool imageChangeColor:[UIColor colorWithHexString:columnMetaModel.color] image:[UIImage imageNamed:@"red_point"]];
                
                [self addSubview:dotView];
                [self.markerDotArray addObject:dotView];
                dotView.frame = CGRectMake(lineX-5, point.y-5, 10, 10);
                dotView.hidden = self.chartOptions.hiddenMarkDot;
                
                if (maxDotY > point.y || maxDotY == 0) {
                    maxDotY = point.y;
                }
            }
        }
    }

    NSArray *xDataArray = self.chartModel.dataInfo.datas[0];
    if (index < xDataArray.count) {
        NSString *xTitleStr = xDataArray[index];
        if (!KStringIsEmpty(xTitleStr)) {
            self.markerView.dateStr = xTitleStr;
            if (!self.chartOptions.showTopDateView) {
                NSMutableArray *markListArray = [NSMutableArray array];
                for (int i=0; i<self.columnMetaArray.count; i++) {
                    SYChartColumnMetaModel *columnMetaModel = self.columnMetaArray[i];
                    
                    SYChartMarkItemModel *markItemModel = [[SYChartMarkItemModel alloc] init];
                    markItemModel.leftText = columnMetaModel.name;
                    if (i < self.y_axis.count) {
                        NSArray *itemArr = self.y_axis[i];
                        if ([itemArr isKindOfClass:[NSArray class]] && !KArrayIsEmpty(itemArr) && index < itemArr.count) {
                            markItemModel.rightText = itemArr[index];
                        }
                    }
                    
                    [markListArray addObject:markItemModel];
                }
                self.markerView.listArray = markListArray.copy;
            }
            
            self.markerView.index = index;

            self.markerView.size = self.markerView.markerSize;
            CGFloat markerX = self.markerRedLine.x+7;
            CGFloat markerY = maxDotY;
            
            if (self.chartOptions.showMarkView) {
                markerY = markerY-self.markerView.size.height*0.5;
            }

            if (self.markerRedLine.x-self.startLayerX > self.startLayerW*0.5) {
                // 右侧
                markerX = self.markerRedLine.x-self.markerView.size.width-7;
            }else{// 左侧
//                markerX = self.markerRedLine.x+7;
            }
            // markerView越过右侧的情况
            if (self.markerView.right > self.width) {
                markerX = self.width - self.markerView.width;
            }

            // markerView越过底部的情况
            if (markerY+self.markerView.size.height > (self.height - self.chartOptions.bottomMargin)) {
                markerY = self.height - self.chartOptions.bottomMargin - self.markerView.size.height;
            }
            // markerView越过顶部的情况
            if (markerY < self.chartOptions.topMargin) {
                markerY = self.chartOptions.topMargin;
            }
            
            // 日期浮窗总是显示在最上方
            if (self.chartOptions.showTopDateView) {
                self.markerView.showTopDateView = self.chartOptions.showTopDateView;
                markerY = self.chartOptions.topMargin;
            }

            CGFloat duration = 0.15;
            if (index == xDataArray.count-1 && self.markerView.x == 0 && self.markerView.y == 0) {// 初始时无动画
                duration = 0;
            }
            
            if (self.markerView.hidden) {
                self.markerView.x = markerX;
                self.markerView.y = markerY;
            }
            self.markerView.hidden = NO;
            
            [UIView animateWithDuration:duration animations:^{
                self.markerView.x = markerX;
                self.markerView.y = markerY;
            }];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chartViewDelegateWithSelectedIndex:)]) {
                [self.delegate chartViewDelegateWithSelectedIndex:index];
            }
            if (self.selectedIndexBlock) {
                self.selectedIndexBlock(index);
            }
        }
    }
    [self bringSubviewToFront:self.markerRedLine];
    [self bringSubviewToFront:self.markerView];
    
    if (self.chartOptions.autoHiddenMarkView) {
        [self performSelector:@selector(hiddenMarkerLine) withObject:nil afterDelay:3];
    }
}

/// 标线默认位置
-(void)defaultLinePlace{
    CGFloat lineX = [self.pointXArray.lastObject floatValue];
    if (self.chartModel.dataInfo.extra && self.chartModel.dataInfo.extra.defaultIndex >= 0) {
        NSInteger defaultIndex = self.chartModel.dataInfo.extra.defaultIndex;
        if (defaultIndex < self.pointXArray.count) {
            lineX = [self.pointXArray[defaultIndex] floatValue];
        }
    }
    
    [self calculateLinePlaceWithPoint:CGPointMake(lineX, self.height - self.chartOptions.bottomMargin)];
}
/// 设置选中位置
-(void)changeSelectedWithIndex:(NSInteger)index{
    CGFloat lineX = [self.pointXArray.lastObject floatValue];
    if (index < self.pointXArray.count) {
        lineX = [self.pointXArray[index] floatValue];
    }
    [self calculateLinePlaceWithPoint:CGPointMake(lineX, self.height - self.chartOptions.bottomMargin)];
}
/// 设置选中项
-(void)changeSelectedWithObject:(id)obj{
    
}

/// 处理横线区间行数和行间差值
-(void)handleHorizontalLineRowAndRelativeValue{
    // y坐标最大值
    CGFloat maxValue = self.maxValue;
    // y坐标最小值
    CGFloat minValue = self.minValue;
    
    // 两线之间对应数据差值
    double bigAvgH = 0;
    NSInteger bigRow = 0;
    NSInteger smallRow = 0;

    BOOL noData = (maxValue == 0 && minValue == 0);
    if (!noData) {
        if (self.chartModel.chartOptions.lineNum > 0) {
            if (maxValue>0 && minValue<0) {// 正负均有值时
                CGFloat allValue = fabs(maxValue) + fabs(minValue);
                // 预估行间距
                CGFloat tempAvgH = allValue / self.chartModel.chartOptions.lineNum;
                // 获取最小绝对值
                CGFloat minFabsValue = MIN(fabs(maxValue), fabs(minValue));
                CGFloat maxFabsValue = MAX(fabs(maxValue), fabs(minValue));
                // 偏小方向划分行数 向上取整
                NSInteger temSmallRow = ceilf(minFabsValue / tempAvgH);
                // 偏大方向划分行数
                NSInteger temBigRow = self.chartModel.chartOptions.lineNum - temSmallRow;
                
                CGFloat minAvgH = 0;
                if (temSmallRow > 0) {
                    minAvgH = minFabsValue / temSmallRow;
                }
                CGFloat maxAvgH = 0;
                if (temBigRow > 0) {
                    maxAvgH = maxFabsValue / temBigRow;
                }
                
                bigAvgH = MAX(minAvgH, maxAvgH);
                
                bigRow = temBigRow;
                smallRow = temSmallRow;
                
            }else{
                // 单方向
                CGFloat maxFabsValue = MAX(fabs(maxValue), fabs(minValue));
                bigAvgH = maxFabsValue / self.chartModel.chartOptions.lineNum;
                bigRow = self.chartModel.chartOptions.lineNum;
            }
            
            self.lineRow = self.chartModel.chartOptions.lineNum;
        }else{
            // 获取最大绝对值
            double maxFabsValue = MAX(fabs(maxValue), fabs(minValue));
            // 偏大方向划分行数
            bigRow = [SYChartTool rowCountWithValueMax:maxFabsValue];

            bigAvgH = maxFabsValue / bigRow;

            if (maxValue>0) {
                if (minValue<0) {
                    // 获取最小绝对值
                    CGFloat minFabsValue = MIN(fabs(maxValue), fabs(minValue));
                    // 偏小方向划分行数 向上取整
                    smallRow = ceilf(minFabsValue/bigAvgH);
                }

                // 总行数
                self.lineRow = bigRow + smallRow;
            }else{
                self.lineRow = bigRow;
            }
        }
    }else{// 没有数据的情况
        NSInteger bigRow = 4;
        self.lineRow = bigRow;
    }
    
    self.lineRelativeValue = bigAvgH;

    // y坐标文本
    self.yTextArray = [self getYLabelTextWithMinValue:minValue maxValue:maxValue smallRow:smallRow bigRow:bigRow lineRelativeValue:bigAvgH leftY:YES];
    // y坐标label最大宽度
    CGFloat maxLabelWidth = [self getMaxYLabelWidthWithTextArray:self.yTextArray];
//    CGFloat maxLabelWidth = [[yLabelWidthStrArray valueForKeyPath:@"@max.floatValue"] doubleValue];
    self.labelWidth = maxLabelWidth;
}
/// 获取纵轴Y坐标文本
-(NSArray *)getYLabelTextWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue smallRow:(NSInteger)smallRow bigRow:(NSInteger)bigRow lineRelativeValue:(double)lineRelativeValue leftY:(BOOL)leftY{
    double bigAvgH = lineRelativeValue;
    
    BOOL forceShowFloat = YES;
    if (self.chartOptions.forceYShowInteger && leftY) {
        CGFloat maxFabsValue = MAX(fabs(maxValue), fabs(minValue));
        if (maxFabsValue/bigRow > 1) {
            forceShowFloat = NO;
        }
    }

    // 存储Y轴坐标文字，计算最大label显示宽度
//    NSMutableArray *yLabelWidthStrArray = [NSMutableArray array];
    NSMutableArray *yTextArray = [NSMutableArray array];
    
    NSInteger zeroIndex = 0;
    for (int i = 0; i < self.lineRow + 1; i++) {
        NSString *text = @"";
        if (maxValue != 0 || minValue != 0) {
            if (smallRow == 0) {// 单方向
                if (maxValue>0) {// 均为正
                    if (forceShowFloat) {
                        text = [NSString stringWithFormat:@"%.2f", i*bigAvgH];
                    }else{
                        text = [NSString stringWithFormat:@"%@", @(ceilf(i*bigAvgH))];
                    }
                    if (i == 0){
                        text = @"0";
                        zeroIndex = i;
                    }
                }else{// 均为负 反向计算
//                    text = [NSString stringWithFormat:@"-%.2f", (self.lineRow+1-i)*bigAvgH];
                    if (forceShowFloat) {
                        text = [NSString stringWithFormat:@"-%.2f", (self.lineRow+1-i)*bigAvgH];
                    }else{
                        text = [NSString stringWithFormat:@"-%@", @(ceilf((self.lineRow+1-i)*bigAvgH))];
                    }
                    
                    if (i == self.lineRow){
                        text = @"0";
                        zeroIndex = i;
                    }
                }
            }else{// 上下均有
                // 判断偏大数在上还是在下
                BOOL maxAtTop = fabs(maxValue) > fabs(minValue);
                if (maxAtTop) {// 偏大数在上
                    if (i < smallRow) {// 小于0的部分
                        if (forceShowFloat) {
                            text = [NSString stringWithFormat:@"-%.2f", (smallRow-i)*bigAvgH];
                        }else{
                            text = [NSString stringWithFormat:@"-%@", @(ceilf((smallRow-i)*bigAvgH))];
                        }
                        
                    }else if (i == smallRow) {
                        text = @"0";
                        zeroIndex = i;
                    }else{// 大于0的部分 maxFabsValue
//                        text = [NSString stringWithFormat:@"%.2f", (i-smallRow)*bigAvgH];
                        
                        if (forceShowFloat) {
                            text = [NSString stringWithFormat:@"%.2f", (i-smallRow)*bigAvgH];
                        }else{
                            text = [NSString stringWithFormat:@"%@", @(ceilf((i-smallRow)*bigAvgH))];
                        }
                    }
                }else{// 偏大数在下
                    if (i < bigRow) {
//                        text = [NSString stringWithFormat:@"-%.2f", (bigRow-i)*bigAvgH];
                        if (forceShowFloat) {
                            text = [NSString stringWithFormat:@"-%.2f", (bigRow-i)*bigAvgH];
                        }else{
                            text = [NSString stringWithFormat:@"-%@", @(ceilf((bigRow-i)*bigAvgH))];
                        }
                    }else if (i == bigRow) {
                        text = @"0";
                        zeroIndex = i;
                    }else{
//                        text = [NSString stringWithFormat:@"%.2f", (i-bigRow)*bigAvgH];
                        if (forceShowFloat) {
                            text = [NSString stringWithFormat:@"%.2f", (i-bigRow)*bigAvgH];
                        }else{
                            text = [NSString stringWithFormat:@"%@", @(ceilf((i-bigRow)*bigAvgH))];
                        }
                    }
                }
            }
            
        }else{
            text = [NSString stringWithFormat:@"%@",@(i)];
        }
        
        [yTextArray addObject:text];
        CGSize size1 = [SYChartTool sizeWithString:text font:kFontScale(self.chartOptions.textFontSize) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
//        if (text.integerValue < 0) {
//            size1.width = size1.width + 3;
//        }
//
//        [yLabelWidthStrArray addObject:@(size1.width+2)];

        if (leftY && size1.height>0) {
            if (size1.height > self.labelHeight) {
                self.labelHeight = size1.height;
            }
        }
    }
    if (leftY) {
        self.zeroIndex = zeroIndex;
    }else{
        self.rightZeroIndex = zeroIndex;
    }
    
    // 当所有数据都是整数时，去掉小数显示
    NSMutableArray *temTextArray = [NSMutableArray array];
    BOOL haveFloat = NO;
    for (NSString *yText in yTextArray) {
        NSString *temText = yText;
        if (!KStringIsEmpty(yText)) {
            if ([yText floatValue] != [yText integerValue]) {
                haveFloat = YES;
            }else{
                temText = [NSString stringWithFormat:@"%@",@([yText integerValue])];
            }
        }
        [temTextArray addObject:temText];
    }
    
    if (haveFloat) {// 没有整数时判断是不是都是只有一位小数
        BOOL haveTwoFloat = NO;
        NSMutableArray *temOneTextArray = [NSMutableArray array];
        for (NSString *yText in yTextArray) {
            if (!KStringIsEmpty(yText)) {
                NSString *temText = [@([yText floatValue]) handleDoubleFormatDecimalPlace:2 round:NO removeEnd:YES];
                NSArray *values = [temText componentsSeparatedByString:@"."];
                if ([yText floatValue] != 0 && values.count>1 && [yText floatValue] != [yText integerValue]) {
                    NSString *lastText = values.lastObject;
                    if (lastText.length == 2) {
                        haveTwoFloat = YES;
                        break;
                    }
                }
                NSString *ontText = [@([yText floatValue]) handleDoubleFormatDecimalPlace:1 round:YES removeEnd:NO];
                if ([yText floatValue] == 0) {
                    ontText = @"0";
                }
                [temOneTextArray addObject:ontText];
            }
        }
        
        if (!haveTwoFloat) {
            [temTextArray removeAllObjects];
            [temTextArray addObjectsFromArray:temOneTextArray];
            haveFloat = NO;
        }
    }
    
    if (!haveFloat && temTextArray.count>0) {
        [yTextArray removeAllObjects];
        [yTextArray addObjectsFromArray:temTextArray];
    }
    
    return yTextArray;
}
/// 获取纵坐标文本最大宽度
-(CGFloat)getMaxYLabelWidthWithTextArray:(NSArray *)textArray{
    CGFloat maxLabelWidth = self.labelWidth;
    if (textArray.count>0) {
        NSMutableArray *temWidthArray = [NSMutableArray array];
        for (NSString *yText in textArray) {
            if (!KStringIsEmpty(yText)) {
                CGSize size1 = [SYChartTool sizeWithString:yText font:kFontScale(self.chartOptions.textFontSize) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
                if (yText.floatValue < 0) {
                    size1.width = size1.width + 3;
                }

                [temWidthArray addObject:@(size1.width+2)];
            }
        }
        
        // y坐标label最大宽度
        maxLabelWidth = [[temWidthArray valueForKeyPath:@"@max.floatValue"] doubleValue];
    }
    return maxLabelWidth;
}
 
/// 获取横坐标文本最大宽度
-(CGFloat)getMaxXLabelWidthWithTextArray:(NSArray *)textArray{
    CGFloat maxXLabelW = 0;
    for (int i = 0; i < textArray.count; i++) {
        NSString *xStr = [NSString stringWithFormat:@"%@", textArray[i]];
        CGSize xSize = [SYChartTool sizeWithString:xStr font:kFontScale(self.chartOptions.textFontSize) maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        if (xSize.width > maxXLabelW) {
            maxXLabelW = xSize.width;
        }
    }
    return maxXLabelW;
}
/// 创建横坐标控件（barMargin为柱状图额外计算逻辑）
-(void)creatXLabelWithXDataArray:(NSArray *)xDataArray barMargin:(CGFloat)barMargin{
    /// 计算最长横坐标宽度
    CGFloat maxXLabelW = [self getMaxXLabelWidthWithTextArray:xDataArray];
    NSMutableArray *xLabelArray = [NSMutableArray array];
    
    BOOL isAngle = NO;// 是否旋转倾斜放置
    UILabel *preLabel = nil;
    UILabel *lastShowLabel = nil;
    for (int i = 0; i < xDataArray.count; i++) {
        [self.dotPointArray addObject:[NSMutableArray array]];
        
        CGFloat x = self.startLayerX + self.chartOptions.startPointPadding + i * self.pointXSpace + barMargin;
        [self.pointXArray addObject:@(x)];

        // 横坐标
        UILabel *xLabel = [[UILabel alloc] init];
        xLabel.numberOfLines = 0;
        xLabel.font = kFontScale(self.chartOptions.textFontSize);
        xLabel.textColor = self.textColor;
        xLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:xLabel];
        [xLabelArray addObject:xLabel];
        
        NSString *xTitleStr = xDataArray[i];
        xLabel.text = xTitleStr;
        [xLabel sizeToFit];
        
        xLabel.size = CGSizeMake(xLabel.width, xLabel.height);
        if (self.chartOptions.xLabelMustFlat) {// 设置最大宽度
            if (self.chartOptions.xLabelFlatMaxWidth> 0 && xLabel.width > self.chartOptions.xLabelFlatMaxWidth) {
                xLabel.width = self.chartOptions.xLabelFlatMaxWidth;
            }
        }
        
        CGFloat xLabelY = self.height-self.chartOptions.bottomMargin+self.chartOptions.xTitleTopSpace;
        xLabel.y = xLabelY;

        // X轴显示逻辑，优先横向放置，展示不开时倾斜，倾斜展示不开时间隔显示
        // 平放方案
        xLabel.centerX = x;
        if (i == 0 && self.chartModel.chartOptions.firstXLabelIndent) {// 第一个
            xLabel.x = x - 3;
        }else if (xLabel.x+xLabel.width>self.contentW && i == xDataArray.count - 1){// 最后一个
            xLabel.x = self.contentW-xLabel.width;
        }
        
        // 处理平放还是旋转倾斜
        if (self.chartModel.chartOptions.xLabelMustFlat) {
            // 必须平放
            if (preLabel && lastShowLabel && xLabel.x < lastShowLabel.right+5) {
                xLabel.hidden = YES;
            }else{
                lastShowLabel = xLabel;
            }
            
            if (i == xDataArray.count-1 && xLabel.hidden) {// 处理最后一个要显示出来
                // 最后一个是隐藏时，将最后一个显示，并它的将前一个已经显示的隐藏
                xLabel.hidden = NO;
                lastShowLabel.hidden = YES;
            }
            
        }else{
            // 判断是否有重叠，标记需要旋转放置
            if (preLabel && xLabel.x < preLabel.right) {
                isAngle = YES;
            }
        }

        preLabel = xLabel;
        
    }
    if (isAngle) {// 旋转放置后距离底部的高度发生变化，需要重置，绘制完横线后再设置label的Y坐标值
        self.chartOptions.bottomMargin = self.chartOptions.bottomMargin - preLabel.height + maxXLabelW;
        
        // X轴label数量过多，计算两个X点的间距低于label倾斜后的宽度则隐藏重叠部分
        // 高度height平方和的平方根
        NSInteger xCount = 1;
        CGFloat angleW = hypotf(preLabel.height, preLabel.height);
        while (angleW > self.pointXSpace*xCount) {
            xCount = xCount+1;
        }
        
        UILabel *lastShowLabel;
        for (int i = 0; i < xLabelArray.count; i++) {
            UILabel *xLabel = xLabelArray[i];
            if (xCount > 1 && i != 0 && i%xCount != 0) {
                xLabel.hidden = YES;
            }else{
                lastShowLabel = xLabel;
            }
            CGFloat xLabelY = self.height-self.chartOptions.bottomMargin+self.chartOptions.xTitleTopSpace;
            xLabel.y = xLabelY;
            
            xLabel.right = [self.pointXArray[i] floatValue];
            
            if (i == xLabelArray.count-1 && xLabel.hidden) {
                // 第一种方案：最后一个是隐藏时，将最后一个显示，并它的将前一个已经显示的隐藏
                xLabel.hidden = NO;
                lastShowLabel.hidden = YES;
                
//                // 第二种方案：最后一个是隐藏时，将最后一个显示，并它向右侧移动
//                xLabel.hidden = NO;
//                xLabel.right = xLabel.right+3;
            }
            
            // 旋转x轴文字角度方案
            CGRect oldFrame = xLabel.frame;
            xLabel.layer.anchorPoint = CGPointMake(1, 0);
            xLabel.frame = oldFrame;
            xLabel.transform = CGAffineTransformMakeRotation(-M_PI/4);
        }
    }
    
    // 因bottomMargin变化导致内容高度重新计算
    self.contentH = self.height - self.chartOptions.topMargin - self.chartOptions.bottomMargin;
}
/// 创建纵坐标控件和横虚线
-(void)creatYLabelAndDashLine{
    // 横线间距
    CGFloat avgHeight = self.contentH / self.lineRow;
    // 横线宽
    CGFloat lineW = self.startLayerW;
    
    // 绘制横虚线，Y坐标label
    for (int i = 0; i < self.yTextArray.count; i++) {
        // 从下向上布局
        // 横虚线
        CGFloat dashLineY = self.height-self.chartOptions.bottomMargin-i*avgHeight;
        UIImageView *dashLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.startLayerX, dashLineY, lineW, 1)];
        CGFloat lineSpacing = 2;
        if (i == 0) {// 横实线
            lineSpacing = 0;
        }
        [SYChartTool drawLineOfDashByCAShapeLayer:dashLine lineLength:2 lineSpacing:lineSpacing lineColor:self.dashLineColor];
        [self addSubview:dashLine];

        // Y坐标label
        UILabel *yLabel = [[UILabel alloc] init];
        yLabel.font = kFontScale(self.chartOptions.textFontSize);
        yLabel.textColor = self.textColor;
        yLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:yLabel];
        
        yLabel.text = self.yTextArray[i];
        yLabel.frame = CGRectMake(self.chartOptions.paddingLeft, dashLineY-self.labelHeight*0.5, self.labelWidth, self.labelHeight);

        if (i == self.zeroIndex) {
            self.zeroY = dashLineY;
        }
    }
}
# pragma mark - 懒加载
-(UILabel *)yTitleLabel{
    if (!_yTitleLabel) {
        _yTitleLabel = [[UILabel alloc] init];
        _yTitleLabel.font = kFontScale(11);
        _yTitleLabel.textColor = self.textColor;
        _yTitleLabel.textAlignment = NSTextAlignmentLeft;
        _yTitleLabel.hidden = YES;
    }
    return _yTitleLabel;
}
/// 悬浮框
-(SYChartMarkView *)markerView{
    if (!_markerView) {
        _markerView = [[SYChartMarkView alloc] init];
        _markerView.hidden = YES;
    }
    return _markerView;
}
/// 指示器竖线red
-(UIImageView *)markerRedLine{
    if (!_markerRedLine) {
        _markerRedLine = [[UIImageView alloc] init];
        _markerRedLine.userInteractionEnabled = NO;
    }
    return _markerRedLine;
}
/// 悬浮框圆点
-(NSMutableArray *)markerDotArray{
    if (!_markerDotArray) {
        _markerDotArray = [NSMutableArray array];
    }
    return _markerDotArray;
}
/// 所有X轴坐标点
-(NSMutableArray *)pointXArray{
    if (!_pointXArray) {
        _pointXArray = [NSMutableArray array];
    }
    return _pointXArray;
}
/// 圆点(始终显示)
-(NSMutableArray *)dotViewArray{
    if (!_dotViewArray) {
        _dotViewArray = [NSMutableArray array];
    }
    return _dotViewArray;
}
/// 圆点
-(NSMutableArray *)dotPointArray{
    if (!_dotPointArray) {
        _dotPointArray = [NSMutableArray array];
    }
    return _dotPointArray;
}
@end
