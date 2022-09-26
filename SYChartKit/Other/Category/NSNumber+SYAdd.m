//
//  NSNumber+SYAdd.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "NSNumber+SYAdd.h"

@implementation NSNumber (SYAdd)
- (NSString *)handleTwoDecimal{
    return [self handleDoubleFormatDecimalPlace:2 round:YES removeEnd:NO];
}
- (NSString *)handleDoubleFormatDecimalPlace:(int)decimalPlace{
    return [self handleDoubleFormatDecimalPlace:decimalPlace round:YES removeEnd:NO];
}

- (NSString *)handleDoubleFormatDecimalPlace:(int)decimalPlace round:(BOOL)round {
    return [self handleDoubleFormatDecimalPlace:decimalPlace round:round removeEnd:NO];
}

- (NSString *)handleDoubleFormatDecimalPlace:(int)decimalPlace round:(BOOL)round removeEnd:(BOOL)removeEnd{
    NSString *valueString = nil;
    // 如果需要四舍五入正常格式化
    if (round) {
        NSString *format = [NSString stringWithFormat:@"%%.%df",decimalPlace];
        valueString = [NSString stringWithFormat:format, [self doubleValue]];
    }
    // 如果不需要四舍五入多保留一位
    else {
        NSString *format = [NSString stringWithFormat:@"%%.%df",decimalPlace + 1];
        valueString = [NSString stringWithFormat:format, [self doubleValue]];
    }
    
    if (valueString && valueString.length > 0) {
        // 判断是否为小数字符串
        NSArray *values = [valueString componentsSeparatedByString:@"."];
        if (values.count == 2) {
            // 拆分出小数并裁至指定位数
            NSString *last = values.lastObject;
            last = [last substringToIndex:decimalPlace];
            
            // 移除末尾无效0
            if (removeEnd) {
                for (int i = (int)last.length - 1; i >= 0; i --) {
                    NSString *item = [last substringFromIndex:i];
                    if ([item isEqualToString:@"0"]) {
                        last = [last substringToIndex:i];
                    }
                }
            }
            
            // 拼接完整
            if (last.length) {
                valueString = [NSString stringWithFormat:@"%@.%@", values[0] ,last];
            }
            else {
                valueString = values[0];
            }
        }
        return valueString;
    }
    return @"";
}
@end
