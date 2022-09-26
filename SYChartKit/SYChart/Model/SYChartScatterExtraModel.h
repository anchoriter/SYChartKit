//
//  SYChartScatterExtraModel.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYChartScatterExtraModel : NSObject
/// 数据名称
@property (nonatomic, copy) NSString *name;
/// 对象象限（右上：1、左上：2、右下：3、左下：4）
@property (nonatomic, assign) NSInteger index;
/// 颜色
@property (nonatomic, strong) NSString *color;
@end

NS_ASSUME_NONNULL_END
