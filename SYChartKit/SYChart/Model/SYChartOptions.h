//
//  SYChartOptions.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 图表类型
typedef NS_ENUM(NSInteger, SYChartType) {
    SYChartType_Line               = 0, // 曲线
    SYChartType_Line_DoubleAxis    = 1, // 双轴曲线
    SYChartType_Bar                = 2, // 柱状图
    SYChartType_WaterfallBar       = 3, // 瀑布图
    SYChartType_Scatter            = 4, // 散点图
    SYChartType_Bubble             = 5, // 气泡图
    SYChartType_BarLine_DoubleAxis = 6, // 多柱曲线双轴图
};

/// 图例位置
typedef NS_ENUM(NSInteger, SYChartLegendPosition) {
    SYChartLegendPosition_None = 0,  // 无
    SYChartLegendPosition_Top = 1,  // 在上
    SYChartLegendPosition_Bottom = 2  // 在底部
};

/// 图例类型
typedef NS_ENUM(NSInteger, SYChartLegendType) {
    SYChartLegendType_Normal = 0,  // 普通样式（图+标题）
    SYChartLegendType_Expand = 1,  // 拓展样式（图+标题+详细数据）
};

@interface SYChartOptions : NSObject
/// 图表类型
@property (nonatomic, assign) SYChartType chartType;
/// 图表纵轴标题
@property (nonatomic, copy) NSString *chartYTitle;
/// 图表右侧纵轴标题
@property (nonatomic, copy) NSString *chartRightYTitle;
/// 是否需要处理数据单位
@property (nonatomic, assign) BOOL showUnitNum;
/// 是否强制取整
@property (nonatomic, assign) BOOL forceYShowInteger;
/// 限制负数为0
@property (nonatomic, assign) BOOL limitMinY;
/// 纵轴行数(默认0)
@property (nonatomic, assign) NSInteger lineNum;
/// 横纵坐标文案字体(默认11)
@property (nonatomic, assign) NSInteger textFontSize;
/// 横坐标文本是否必须水平（默认NO，放置不开时优先倾斜，再倾斜节选；YES：必须水平，放置不开时节选）
@property (nonatomic, assign) BOOL xLabelMustFlat;
/// 首位横坐标文本是否需要缩进（默认：NO  和点中心对齐）
@property (nonatomic, assign) BOOL firstXLabelIndent;
/// 横坐标文本水平方向最大宽度(默认40，仅在xLabelMustFlat为YES时生效)
@property (nonatomic, assign) CGFloat xLabelFlatMaxWidth;
/// 是否显示指定日期浮窗
@property (nonatomic, assign) BOOL showTopDateView;

/// 是否显示浮窗 默认NO
@property (nonatomic, assign) BOOL showMarkView;
/// 是否自动隐藏浮窗 默认NO
@property (nonatomic, assign) BOOL autoHiddenMarkView;
/// 是否显示浮窗纵向虚线 默认NO
@property (nonatomic, assign) BOOL showMarkLine;
/// 是否隐藏浮窗纵向虚线交点圆点 默认NO
@property (nonatomic, assign) BOOL hiddenMarkDot;

/// 是否初始选中数据
@property (nonatomic, assign) BOOL showSelected;

/// 是否显示mock数据 默认NO
@property (nonatomic, assign) BOOL showMock;
/// 图例位置 默认：None不展示
@property (nonatomic, assign) SYChartLegendPosition legendPosition;

@property (nonatomic, assign) SYChartLegendType legendType;
/// 图例和图表间距
@property (nonatomic, assign) CGFloat legendChartSpace;
/// 图例高度 默认20
@property (nonatomic, assign) CGFloat legendHeight;
/// 图例单行列数（默认3）
@property (nonatomic, assign) CGFloat legendColumnNum;

/// 柱子的宽度
@property (nonatomic, assign) CGFloat barWidth;
/// 柱子的最小间距
@property (nonatomic, assign) CGFloat barMinSpace;
/// 柱子显示整数
@property (nonatomic, assign) BOOL barShowInteger;

# pragma mark - 间距
/// 内容左边距 (默认:10)
@property (nonatomic, assign) CGFloat paddingLeft;
/// 内容右边距 (默认:10)
@property (nonatomic, assign) CGFloat paddingRight;
/// X轴距离底部间距 (默认:40)
@property (nonatomic, assign) CGFloat bottomMargin;
/// 绘图区域距离顶部间距 (默认:30)
@property (nonatomic, assign) CGFloat topMargin;
/// 纵坐标文本距离坐标轴距离（默认3）
@property (nonatomic, assign) CGFloat yTitleRightSpace;
/// 横坐标文本距离坐标轴距离（默认8）
@property (nonatomic, assign) CGFloat xTitleTopSpace;
/// 横线绘制区域和右边间距
@property (nonatomic, assign) CGFloat layerRightMargin;

/// 开始点和结束点的缩进
@property (nonatomic, assign) CGFloat startPointPadding;
@end

NS_ASSUME_NONNULL_END
