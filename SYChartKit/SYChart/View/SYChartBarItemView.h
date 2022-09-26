//
//  SYChartBarItemView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//
// 单个柱子视图

#import <UIKit/UIKit.h>
#import "SYChartBarItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYChartBarItemView : UIView

/// 单柱子包含的数据（所有柱子的数组个数固定）
@property (nonatomic, strong) NSArray <SYChartBarItemModel *>*datasArray;
@end

NS_ASSUME_NONNULL_END
