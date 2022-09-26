//
//  SYChartBarItemModel.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYChartBarItemModel : NSObject
/// 单柱子的高度比例
@property (nonatomic, assign) CGFloat scale;
/// 单柱子的数据
@property (nonatomic, assign) CGFloat value;

@property (nonatomic, strong) UIColor *color;
/// 是否是多柱（默认NO：单柱子或堆积）
@property (nonatomic, assign) BOOL isMoreBar;
@end

NS_ASSUME_NONNULL_END
