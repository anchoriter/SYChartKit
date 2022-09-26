//
//  SYChartDataInfoModel.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartDataInfoModel.h"

@implementation SYChartDataInfoModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{
            @"columnMetas" : SYChartColumnMetaModel.class,
            @"datas" : NSArray.class
    };
}
@end
