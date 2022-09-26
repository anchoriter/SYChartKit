//
//  SYChartExtraModel.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>
#import "SYChartScatterExtraModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SYChartExtraModel : NSObject
/// 默认选中（默认-1，代表没有此数据）
@property (nonatomic, assign) NSInteger defaultIndex;

/// 趋势图颜色（以逗号分割颜色）
@property (nonatomic, copy) NSString *chartFileColor;
/// y轴标题
@property (nonatomic, copy) NSString *y_title;
/// 图表名称
@property (nonatomic, copy) NSString *chartAlias;


# pragma mark - 以下为散点气泡图拓展属性
/// 散点图象限描述
@property (nonatomic, strong) NSArray <SYChartScatterExtraModel *>*scatterInfo;
/// 四象限描述信息
@property (nonatomic, strong) NSArray <NSString *>*quadrantDescArray;
/// 四极描述信息
@property (nonatomic, strong) NSArray <NSString *>*quadrantArray;
/// x轴中位数
@property (nonatomic, assign) double xmedian;
/// y轴中位数
@property (nonatomic, assign) double ymedian;
@end

NS_ASSUME_NONNULL_END
