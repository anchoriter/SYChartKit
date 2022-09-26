//
//  SYChartBaseModel.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>
#import "SYChartDataInfoModel.h"
#import "SYChartOptions.h"
#import "SYChartTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYChartBaseModel : NSObject
/// 图表名称
@property (nonatomic, copy) NSString *chartName;
/// 图表id
@property (nonatomic, copy) NSString *chartId;
/// 图表类型（line    bar）
@property (nonatomic, copy) NSString *chartType;
/// 图表数据
@property (nonatomic, strong) SYChartDataInfoModel *dataInfo;
/// 图表配置
@property (nonatomic, strong) SYChartOptions *chartOptions;

@end

NS_ASSUME_NONNULL_END
