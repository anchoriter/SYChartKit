//
//  SYChartViewDelegate.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>
#import "SYChartLegendView.h"
@class SYChartBaseModel;

NS_ASSUME_NONNULL_BEGIN

@protocol SYChartViewDelegate <NSObject>

@optional
/// 选中的下标
- (void)chartViewDelegateWithSelectedIndex:(NSInteger)index;
/// 选中项
- (void)chartViewDelegateWithSelectedObject:(id)obj;
/// 自定义图例视图
-(SYChartLegendView *)chartViewDelegateCustomLegendView;

/// 纵轴标题
-(NSString *)chartViewWithModel:(SYChartBaseModel *)chartModel unit:(ChartUnitNum)unit;
/// 右侧纵轴标题
-(NSString *)chartViewWithModel:(SYChartBaseModel *)chartModel rightUnit:(ChartUnitNum)unit;
@end

NS_ASSUME_NONNULL_END
