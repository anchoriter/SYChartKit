//
//  SYChartExtraModel.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartExtraModel.h"

@implementation SYChartExtraModel
-(instancetype)init{
    self = [super init];
    if (self) {
        self.defaultIndex = -1;
        self.xmedian = -0.01;
        self.ymedian = -0.01;
    }
    return self;
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{
            @"scatterInfo" : SYChartScatterExtraModel.class,
            @"quadrantDescArray" : NSString.class,
            @"quadrantArray" : NSString.class
    };
}
@end
