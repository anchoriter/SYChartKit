//
//  SYChartLegendExpandView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//
//  图例——展示颜色、标题、详细数据

#import "SYChartLegendView.h"
@class SYChartBaseModel;

NS_ASSUME_NONNULL_BEGIN

@interface SYChartLegendExpandView : SYChartLegendView

/// 绑定数据
-(void)bindChartViewModel:(SYChartBaseModel *)chartModel;

@end


@interface SYChartLegendExpandItemView : UIView
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@end
NS_ASSUME_NONNULL_END
