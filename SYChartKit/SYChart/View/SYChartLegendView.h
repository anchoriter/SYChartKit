//
//  SYChartLegendView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//
//  图例——仅展示颜色和标题

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYChartLegendView : UIView
-(void)setLegendTitleArray:(NSArray *)titleArray colorArray:(NSArray *)colorArray itemSize:(CGSize)itemSize;

/// 选中某个数据时调用
-(void)showLegendDataWithIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
