//
//  SYChartScatterView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//  散点图+气泡图

#import "SYChartCommentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYChartScatterView : SYChartCommentView

/// 设置选中象限虚线位置
-(void)changeDashLineBorderWithIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
