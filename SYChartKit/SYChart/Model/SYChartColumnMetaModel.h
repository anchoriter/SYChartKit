//
//  SYChartColumnMetaModel.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SYChartShowType) {// 单条数据的展示形式
    SYChartShowType_Line = 0,//曲线
    SYChartShowType_Curve = 1,//折线
    SYChartShowType_Bar = 2,//柱子
    SYChartShowType_StackedBar = 3,//堆积柱子
    SYChartShowType_WaterfallBar = 4,//瀑布柱子
};

@interface SYChartColumnMetaModel : NSObject
/// 数据名称
@property (nonatomic, copy) NSString *name;
/// 数据下标（用于查询datas中的数据）
@property (nonatomic, assign) NSInteger index;
/// 数据类型（0：X轴  1：Y轴）
@property (nonatomic, assign) NSInteger fieldType;
/// 颜色
@property (nonatomic, strong) NSString *color;
/// 展示样式（默认：0曲线）
@property (nonatomic, assign) SYChartShowType showType;
/// 是否显示面积填充 默认NO
@property (nonatomic, assign) BOOL showAreaLayer;
/// 是否显示点
@property (nonatomic, assign) BOOL showDot;
/// 是否显示点至X轴虚线
@property (nonatomic, assign) BOOL showDotLine;
/// 是否是右侧轴数据
@property (nonatomic, assign) BOOL isRightAxis;
@end

NS_ASSUME_NONNULL_END
