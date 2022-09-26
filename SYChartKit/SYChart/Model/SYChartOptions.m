//
//  SYChartOptions.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartOptions.h"

@implementation SYChartOptions
-(instancetype)init{
    self = [super init];
    if (self) {
        self.legendHeight = 20*kScreenScale;
        self.paddingLeft = 10*kScreenScale;
        self.paddingRight = 10*kScreenScale;
        self.topMargin = 30*kScreenScale;
        self.bottomMargin = 40*kScreenScale;
        self.textFontSize = 11*kScreenScale;
        self.barWidth = 8*kScreenScale;
        self.barMinSpace = 3*kScreenScale;
        self.startPointPadding = 0;
        self.legendColumnNum = 3;
        self.xLabelFlatMaxWidth = 40*kScreenScale;
        self.yTitleRightSpace = 3;
        self.xTitleTopSpace = 8;
        self.layerRightMargin = 0;
    }
    return self;
}
@end
