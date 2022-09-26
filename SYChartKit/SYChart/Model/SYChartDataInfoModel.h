//
//  SYChartDataInfoModel.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//  图表数据

#import <Foundation/Foundation.h>
#import "SYChartColumnMetaModel.h"
#import "SYChartExtraModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYChartDataInfoModel : NSObject
/// 元数据
@property (nonatomic, strong) NSArray <SYChartColumnMetaModel *>*columnMetas;
/// 详细数据 (字符数组下标 0:X轴数据  1...:详细数据)
@property (nonatomic, strong) NSArray <NSArray *>*datas;
/// 拓展
@property (nonatomic, strong) SYChartExtraModel *extra;
@end

NS_ASSUME_NONNULL_END
