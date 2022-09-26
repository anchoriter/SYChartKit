//
//  SubBaseViewController.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/26.
//

#import <UIKit/UIKit.h>
#import "SYChart.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubBaseViewController : UIViewController
/// 图表
@property (nonatomic, strong) SYChartView *chartView;

/// 本地json数据文件名
@property (nonatomic, strong) NSString *jsonName;
@end

NS_ASSUME_NONNULL_END
