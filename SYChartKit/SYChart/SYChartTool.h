//
//  SYChartTool.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>

/// 判断字符串是否为空
#define KStringIsEmpty(str) ([SYChartTool judgeStringIsEmpty:str] ? YES : NO )

NS_ASSUME_NONNULL_BEGIN

struct ChartUnitNum {
    NSString *unit;
    int unitNum;
};
typedef struct ChartUnitNum ChartUnitNum;
CG_INLINE ChartUnitNum
MaxUnitNumMake(NSString *unit, int unitNum)
{
    ChartUnitNum obj;
    obj.unit = unit;
    obj.unitNum = unitNum;
    return obj;
};

@interface SYChartTool : NSObject

/**
 *  返回图表单位（单位 | 精度值）
 *
 *  @param valueMax 数组中的最大值
 *  @param rowNum 计算后的结果必须大于1
 *
 *  @return 图表表头
 */
+(ChartUnitNum)getUnitNum:(CGFloat)valueMax rowNum:(NSInteger)rowNum;
/// 通过最大值和最小值，获取合适的单位
+(ChartUnitNum)getUnitNumWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue rowNum:(NSInteger)rowNum;
/// 通过单位换算成最终值
+(CGFloat)conversionValueWithOldValue:(CGFloat)oldValue unitNum:(ChartUnitNum)unitNum;
/// 获取最大值
+(double)getMaxValueWithDataArray:(NSArray *)dataArray;
/// 获取最小值
+(double)getMinValueWithDataArray:(NSArray *)dataArray;
/**
 *  返回图表适合分的行数(4|5|6行)
 *
 *  @param valueMax 数组中的最大值
 *
 *  @return 图表适合分的行数
 */
+(NSInteger)rowCountWithValueMax:(CGFloat)valueMax;
/**
 *  返回适合图表分布的范围内最大值
 *
 *  @param valueMax 数组中的最大值
 *
 *  @return 图表适合的范围内最大值
 */
+(CGFloat)rangeMaxWithValueMax:(CGFloat)valueMax;

/// 中间的点
+(CGPoint)midPointForPointsWithP1:(CGPoint)p1 p2:(CGPoint)p2;
/// 控制点
+(CGPoint)controlPointForPointsWithP1:(CGPoint)p1 p2:(CGPoint)p2;
/// 绘制线条
+(void)drawLineWithPath:(UIBezierPath *)linePath lineColor:(UIColor *)lineColor lineLayer:(CAShapeLayer *)lineLayer superLayer:(CALayer *)superLayer;
/// 绘制渐变色面积图
+(void)drawLinearGradientWithPath:(UIBezierPath *)path gradientLayer:(CAGradientLayer *)gradientLayer progressLayer:(CAShapeLayer *)progressLayer color:(NSString *)colorHex size:(CGSize)size superLayer:(CALayer *)superLayer;
/// 绘制纵向虚线
+ (CAShapeLayer *)drawDottedLineWithBeginPoint:(CGPoint)point1 withEndPoint:(CGPoint)point2 color:(NSString *)color superLayer:(CALayer *)superLayer;

+(UIImage*)imageChangeColor:(UIColor*)color image:(UIImage *)image;
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;
/// 返回字符串所占用的尺寸.
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize;
/// 富文本frameSize
+ (CGSize)getSizeToAttributedString:(NSAttributedString *)String RectWithSize:(CGSize)size;
///判断string 是否为空
+ (BOOL)judgeStringIsEmpty:(NSString *)string;
/**
 画虚线的方法

 @param lineView 通过该view生成虚线
 @param lineLength 每段线的长度
 @param lineSpacing 线和线之间的间距
 @param lineColor 线的颜色
 */
+(void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;
+(void)drawHLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

// 读取本地JSON文件
+ (NSDictionary *)readLocalJsonFileWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
