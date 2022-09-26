//
//  SYChartView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <UIKit/UIKit.h>
#import "SYChartView.h"
#import "SYChartBaseModel.h"
#import "SYChartViewDelegate.h"
#import "SYChartTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYChartView : UIView
 
@property (nonatomic, weak) id <SYChartViewDelegate>delegate;
/// 配置和数据
@property (nonatomic, strong, readonly) SYChartBaseModel *chartModel;
/// 绑定数据
-(void)bindChartViewModel:(SYChartBaseModel *)chartModel;

/// 设置选中位置
-(void)changeSelectedWithIndex:(NSInteger)index;
/// 设置选中项
-(void)changeSelectedWithObject:(id)obj;
/// 隐藏指示器竖线
-(void)hiddenMarkerLine;
@end

NS_ASSUME_NONNULL_END
