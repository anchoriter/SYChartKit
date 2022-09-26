//
//  SYChartTool.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartTool.h"

@implementation SYChartTool
/**
 *  返回图表单位（单位 | 精度值）
 *
 *  @param valueMax 数组中的最大值
 *
 *  @return 图表表头
 */
+(ChartUnitNum)getUnitNum:(CGFloat)valueMax rowNum:(NSInteger)rowNum{
    CGFloat abs_value = fabs(valueMax);
    ChartUnitNum obj;
    obj.unit = @"";
    obj.unitNum = 1;
    
    if (abs_value == 0) {
        return obj;
    }
    
    if (abs_value/100000000 >= 1) {
        obj.unit = @"亿";
        obj.unitNum = 100000000;
        
        CGFloat value = abs_value/100000000;
        if (value/rowNum<1) {// 降级处理
            obj.unit = @"万";
            obj.unitNum = 10000;
        }
    }else if (abs_value/10000 >= 1){
        obj.unit = @"万";
        obj.unitNum = 10000;
        
        CGFloat value = abs_value/10000;
        if (value/rowNum<1) {// 降级处理
            obj.unit = @"";
            obj.unitNum = 1;
        }
    }
    
    return obj;
    
}
/// 通过最大值和最小值，获取合适的单位
+(ChartUnitNum)getUnitNumWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue rowNum:(NSInteger)rowNum{
    ChartUnitNum maxUnitNum = [SYChartTool getUnitNum:maxValue rowNum:rowNum];
    ChartUnitNum minUnitNum = [SYChartTool getUnitNum:minValue rowNum:rowNum];
    
    ChartUnitNum unitNum = maxUnitNum;
    if (maxUnitNum.unitNum > 1 || minUnitNum.unitNum > 1) {
        if (maxUnitNum.unitNum < minUnitNum.unitNum) {
            unitNum = minUnitNum;
        }
    }
    return unitNum;
}
/// 通过单位换算成最终值
+(double)conversionValueWithOldValue:(CGFloat)oldValue unitNum:(ChartUnitNum)unitNum{
    double temValue = oldValue/unitNum.unitNum;
    if (oldValue != temValue*unitNum.unitNum) {
        // 有小数
        double floatValue = [@(oldValue) doubleValue]/unitNum.unitNum;
        oldValue = [SYChartTool rangeMaxWithValueMax:floatValue];
        if (floatValue < 0) {
            oldValue = -oldValue;
        }
    }else{
        oldValue = temValue;
    }
    return oldValue;
}
/// 获取最大值
+(double)getMaxValueWithDataArray:(NSArray *)dataArray{
    double maxValue = 0.0;
    for (int i=0; i<dataArray.count; i++) {
        double maxValue1 = 0.0;
        id obj = dataArray[i];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *temArr = obj;
            maxValue1 = [[temArr valueForKeyPath:@"@max.doubleValue"] doubleValue];
            
        }else if ([obj isKindOfClass:[NSNumber class]]) {
            maxValue1 = [obj doubleValue];
        }
        if (i==0) {
            maxValue = maxValue1;
        }
        if (maxValue < maxValue1) {
            maxValue = maxValue1;
        }
    }
    return maxValue;
}
/// 获取最小值
+(double)getMinValueWithDataArray:(NSArray *)dataArray{
    double minValue = 0.0;
    for (int i=0; i<dataArray.count; i++) {
        double minValue1 = 0.0;
        id obj = dataArray[i];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *temArr = obj;
            minValue1 = [[temArr valueForKeyPath:@"@min.doubleValue"] doubleValue];
            
        }else if ([obj isKindOfClass:[NSNumber class]]) {
            minValue1 = [obj floatValue];
        }
        if (i==0) {
            minValue = minValue1;
        }
        if (minValue > minValue1) {
            minValue = minValue1;
        }
    }
    return minValue;
}

+(NSInteger)rowCountWithValueMax:(CGFloat)valueMax {
    NSInteger number1 = 0;
    NSInteger number2 = 0;
    NSInteger number3 = 0;
    NSInteger rowCount = 0;
    NSString *valueMaxStr = [NSString stringWithFormat:@"%f",valueMax];
    for (int i = 0; i < valueMaxStr.length; i++) {
        NSString *c = [NSString stringWithFormat:@"%c",[valueMaxStr characterAtIndex:i]];
        if (![c isEqualToString:@"0"]&&![c isEqualToString:@"."]) {
            if (number1 == 0) {
                number1 = [c integerValue];
                if (number1 > 2) {
                    break;
                }
            } else if (number2 == 0) {
                number2 = [c integerValue];
                if (number2 != 2) {
                    break;
                }
            } else if (number3 == 0) {
                number3 = [c integerValue];
                break;
            }
        }
    }
    if (number1 > 2) {
        switch (number1) {
            case 3:
            case 6:
            case 7:
            case 9:
                rowCount = 4;
                break;
            case 4:
            case 8:
                rowCount = 5;
                break;
            case 5:
                rowCount = 6;
            default:
                break;
        }
    } else if (number1 <= 2) {
        if (number1 == 1) {
            switch (number2) {
                case 0:
                case 1:
                case 2:
                {
                    if (number3 < 5) {
                        rowCount = 5;
                    } else if (number3 >= 5) {
                        rowCount = 6;
                    }
                    break;
                }
                case 3:
                case 4:
                    rowCount = 6;
                    break;
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    rowCount = 4;
                    break;
                default:
                    break;
            }
        } else if (number1 == 2) {
            switch (number2) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                    rowCount = 5;
                    break;
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    rowCount = 6;
                    break;
                default:
                    break;
            }
        }
    }
    return rowCount;
}

+(CGFloat)rangeMaxWithValueMax:(CGFloat)valueMax {
//    CGFloat rangeMax = 0.0;
//
//    int maxInt = ceilf(valueMax);
//    int remNum = maxInt%5; // 1
//    if (remNum == 0) {
//        rangeMax = maxInt;
//    }else {
//        rangeMax = maxInt+5-remNum;
//    }

    
    
    NSInteger number1 = 0;
    NSInteger number2 = 0;
    NSInteger number3 = 0;
    CGFloat rangeMax = 0.0;
    NSString *valueMaxStr = [NSString stringWithFormat:@"%f",valueMax];
    for (int i = 0; i < valueMaxStr.length; i++) {
        NSString *c = [NSString stringWithFormat:@"%c",[valueMaxStr characterAtIndex:i]];
        if (![c isEqualToString:@"0"]&&![c isEqualToString:@"."]) {
            if (number1 == 0) {
                number1 = [c integerValue];
                if (number1 > 2) {
                    break;
                }
            } else if (number2 == 0) {
                number2 = [c integerValue];
                if (number2 != 2) {
                    break;
                }
            } else if (number3 == 0) {
                number3 = [c integerValue];
                break;
            }
        }
    }
    if (number1 > 2) {
        switch (number1) {
            case 3:
                rangeMax = 4;
                break;
            case 4:
                rangeMax = 5;
                break;
            case 5:
                rangeMax = 6;
                break;
            case 6:
            case 7:
                rangeMax = 8;
                break;
            case 8:
            case 9:
                rangeMax = 10;
                break;
            default:
                break;
        }
    } else if (number1 <= 2) {
        if (number1 == 1) {
            switch (number2) {
                case 0:
                case 1:
                case 2:
                {
                    if (number3 < 5) {
                        rangeMax = 1.25;
                    } else if (number3 >= 5) {
                        rangeMax = 1.5;
                    }
                    break;
                }
                case 3:
                case 4:
                    rangeMax = 1.5;
                    break;
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    rangeMax = 2.0;
                    break;
                default:
                    break;
            }
        } else if (number1 == 2) {
            switch (number2) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                    rangeMax = 2.5;
                    break;
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    rangeMax = 3.0;
                    break;
                default:
                    break;
            }
        }
    }
    CGFloat n = 1;
    for (int i = 0; i < valueMaxStr.length; i++) {
        if (valueMax > 1) {
            NSString *c = [NSString stringWithFormat:@"%c",[valueMaxStr characterAtIndex:i]];
            if (![c isEqualToString:@"."]) {
                n = n*10;
            } else {
                n = n/10;
                break;
            }
        } else {
            NSString *c = [NSString stringWithFormat:@"%c",[valueMaxStr characterAtIndex:i]];
            if ([c isEqualToString:@"0"]) {
                n = n/10;
            } else if (![c isEqualToString:@"."]){
                break;
            }
        }
    }
    
    
    // 补0，避免以上步骤将数值位数缩减
    CGFloat value = rangeMax*n;
    NSString *valueStr = [NSString stringWithFormat:@"%f",value];
    
    NSArray *valueArray = [valueStr componentsSeparatedByString:@"."];
    NSArray *valueMaxArray = [valueMaxStr componentsSeparatedByString:@"."];
    
    NSString *fStr = valueArray.firstObject;
    if ([fStr hasPrefix:@"-"]) {
        fStr = [fStr substringFromIndex:1];
    }
    
    NSString *mfStr = valueMaxArray.firstObject;
    if ([mfStr hasPrefix:@"-"]) {
        mfStr = [mfStr substringFromIndex:1];
    }
    
    NSInteger le = mfStr.length - fStr.length;
    if (le > 0) {
//        NSArray *valueArray = [valueStr componentsSeparatedByString:@"."];
        for (int i=0; i<le; i++) {
            fStr = [fStr stringByAppendingString:@"0"];
        }
        
        return fStr.floatValue;
    }else{
        return rangeMax*n;
    }
}

/// 中间的点
+(CGPoint)midPointForPointsWithP1:(CGPoint)p1 p2:(CGPoint)p2{
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}
/// 控制点
+(CGPoint)controlPointForPointsWithP1:(CGPoint)p1 p2:(CGPoint)p2{
    CGPoint controlPoint = [SYChartTool midPointForPointsWithP1:p1 p2:p2];
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    if (p1.y < p2.y) controlPoint.y += diffY;
    else if (p1.y > p2.y) controlPoint.y -= diffY;

    return controlPoint;
}

/// 绘制线条
+(void)drawLineWithPath:(UIBezierPath *)linePath lineColor:(UIColor *)lineColor lineLayer:(CAShapeLayer *)lineLayer superLayer:(CALayer *)superLayer{
    //layer
    lineLayer.lineWidth = 2;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.strokeColor = lineColor.CGColor;
    lineLayer.path = linePath.CGPath;
    [superLayer addSublayer:lineLayer];

//    // 绘制动画效果
//    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    basicAnimation.fromValue = @(0);
//    basicAnimation.toValue = @(1);
//    basicAnimation.duration = kGraphAnimation;
//    basicAnimation.repeatCount = 1;
//    [layer addAnimation:basicAnimation forKey:@"123"];
}
/// 绘制渐变色面积图
+(void)drawLinearGradientWithPath:(UIBezierPath *)path gradientLayer:(CAGradientLayer *)gradientLayer progressLayer:(CAShapeLayer *)progressLayer color:(NSString *)colorHex size:(CGSize)size superLayer:(CALayer *)superLayer{

    [superLayer addSublayer:gradientLayer];

    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [gradientLayer setColors:@[(__bridge id)[UIColor colorWithHexString:colorHex alpha:0.1].CGColor, (__bridge id)[UIColor colorWithHexString:colorHex alpha:0.05].CGColor, (__bridge id)[UIColor colorWithHexString:colorHex alpha:0.01].CGColor]];
    
    //渐变方向水平
    gradientLayer.locations = @[@0.3, @0.5, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);

    progressLayer.path = path.CGPath;
    progressLayer.lineWidth = 3;
    progressLayer.lineCap = kCALineCapRound;// 圆形端点
    progressLayer.strokeColor = [UIColor clearColor].CGColor;

    //用progressLayer来截取渐变层
    [gradientLayer setMask:progressLayer];

//    // 绘制动画效果
//    CABasicAnimation *animationColor = [CABasicAnimation animationWithKeyPath:@"bounds"];
//    animationColor.duration = kGraphAnimation;
//    animationColor.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, self.height)];
//    animationColor.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.contentW, self.height)];
//    animationColor.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//     [gradientLayer addAnimation:animationColor forKey:@"animationColorBounds"];
//
//    CABasicAnimation *animationColorPosition = [CABasicAnimation animationWithKeyPath:@"position"];
//   animationColorPosition.duration = kGraphAnimation;
//   animationColorPosition.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, gradientLayer.position.y)];
//   animationColorPosition.toValue = [NSValue valueWithCGPoint:CGPointMake(self.contentW/2, gradientLayer.position.y)];
//   animationColorPosition.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionLinear];
//   [gradientLayer addAnimation:animationColorPosition forKey:@"animationColorPosition"];
}

/// 绘制纵向虚线
+ (CAShapeLayer *)drawDottedLineWithBeginPoint:(CGPoint)point1 withEndPoint:(CGPoint)point2 color:(NSString *)color superLayer:(CALayer *)superLayer{

    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1;
    lineLayer.strokeColor = [UIColor colorWithHexString:color].CGColor;

    UIBezierPath *pointPath = [UIBezierPath bezierPath];

    [pointPath moveToPoint:point1];
    [pointPath addLineToPoint:point2];
    lineLayer.path = pointPath.CGPath;
    [superLayer addSublayer:lineLayer];

    [lineLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [lineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLayer.lineWidth], [NSNumber numberWithInt:2], nil]];

    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(path, NULL,point2.x, point2.y);
    [lineLayer setPath:path];
    CGPathRelease(path);

    return lineLayer;
}

+(UIImage*)imageChangeColor:(UIColor*)color image:(UIImage *)image{
    //获取画布
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    //画笔沾取颜色
    [color setFill];
    
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    //绘制一次
    [image drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
    //再绘制一次
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    //获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    if (cornerRadius > 0) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:cornerRadius];
        [path addClip];
        [path fill];
    } else {
        CGContextFillRect(context, rect);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/// 返回字符串所占用的尺寸.
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
}
/// 富文本frameSize
+ (CGSize)getSizeToAttributedString:(NSAttributedString *)String RectWithSize:(CGSize)size {
    if (!String) {
        return CGSizeZero;
    }
    CGSize frameSize = [String boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    return  frameSize;
}
///判断string 是否为空
+ (BOOL)judgeStringIsEmpty:(NSString *)string {
    /*
     ([str isKindOfClass:[NSNull class]] ||  [str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"] || str == nil || [str length] < 1 ? YES : NO )
     */
    if (!string) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([string isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([string isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([string isEqualToString:@"null"]) {
        return YES;
    }
    if ([string length] < 1) {
        return YES;
    }
    return NO;
}

/**
 画虚线的方法

 @param lineView 通过该view生成虚线
 @param lineLength 每段线的长度
 @param lineSpacing 线和线之间的间距
 @param lineColor 线的颜色
 */
+(void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}
+(void)drawHLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
//    [shapeLayer setPosition:CGPointMake(CGRectGetHeight(lineView.frame) / 2, CGRectGetWidth(lineView.frame))];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame), CGRectGetHeight(lineView.frame)/2)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,0, CGRectGetHeight(lineView.frame));
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
    
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextBeginPath(context);
//    CGContextSetLineWidth(context,1);
//    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
//    CGFloat lengths[] = {lineLength,lineSpacing};
//    CGContextSetLineDash(context, 0, lengths,2);
//    CGContextMoveToPoint(context, 0, 0);
//    CGContextAddLineToPoint(context, 0, CGRectGetHeight(lineView.frame));
//    CGContextStrokePath(context);
//    CGContextClosePath(context);
}

// 读取本地JSON文件
+ (NSDictionary *)readLocalJsonFileWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return nil;
}
@end
