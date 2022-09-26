//
//  NSNumber+SYAdd.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (SYAdd)
/// 数字格式化
/// @param decimalPlace 拆分出小数并裁至指定位数
/// @param round 是否四舍五入正常格式化
/// @param removeEnd 是否移除末尾0
- (NSString *)handleDoubleFormatDecimalPlace:(int)decimalPlace round:(BOOL)round removeEnd:(BOOL)removeEnd;
/// 数字格式化 默认不移除末尾0
- (NSString *)handleDoubleFormatDecimalPlace:(int)decimalPlace round:(BOOL)round;
/// 数字格式化 默认四舍五入 不移除末尾0
- (NSString *)handleDoubleFormatDecimalPlace:(int)decimalPlace;
/// 数字格式化 默认两位小数 四舍五入 不移除末尾0
- (NSString *)handleTwoDecimal;

@end

NS_ASSUME_NONNULL_END
