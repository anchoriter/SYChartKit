//
//  SYChartCommentView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <UIKit/UIKit.h>
#import "SYChartBaseModel.h"
#import "SYChartViewDelegate.h"
#import "SYChartMarkView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYChartCommentView : UIView
@property (nonatomic, weak) id <SYChartViewDelegate>delegate;

@property (nonatomic, copy) void (^selectedIndexBlock)(NSInteger index);

/// 绑定数据
-(void)bindChartViewModel:(SYChartBaseModel *)chartModel;
/// 刷新图表
-(void)reloadChartView;


# pragma mark - 其它
/// 配置和数据
@property (nonatomic, strong) SYChartBaseModel *chartModel;
/// 图表配置
@property (nonatomic, strong) SYChartOptions *chartOptions;
/// 所有点的数据
@property (nonatomic, strong, nullable) NSArray *y_axis;
/// 所有线的配置数据
@property (nonatomic, strong, nullable) NSArray <SYChartColumnMetaModel *>*columnMetaArray;
/// 线颜色
@property (nonatomic, strong) NSArray *colorArray;
/// 纵坐标文本
@property (nonatomic, strong, nullable) NSArray *yTextArray;

/// 滑动手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
/// 是否是拖动
@property (nonatomic, assign) BOOL isMoveing;
/// 两线之间对应数据差值
@property (nonatomic, assign) double lineRelativeValue;

@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double minValue;

/// 0线的位置
@property (nonatomic, assign) NSInteger zeroIndex;
/// 右轴0线的位置
@property (nonatomic, assign) NSInteger rightZeroIndex;

# pragma mark - 公共视图相关
/// Y坐标标题
@property (nonatomic, strong) UILabel *yTitleLabel;
/// 文本颜色
@property (nonatomic, strong) UIColor *textColor;
/// 虚线颜色
@property (nonatomic, strong) UIColor *dashLineColor;

/// 指示器竖线red
@property (nonatomic, strong) UIImageView *markerRedLine;
/// 悬浮框
@property (nonatomic, strong) SYChartMarkView *markerView;
/// 悬浮框圆点
@property (nonatomic, strong) NSMutableArray *markerDotArray;

/// 所有X轴坐标点
@property (nonatomic, strong) NSMutableArray *pointXArray;
/// 圆点(始终显示)
@property (nonatomic, strong) NSMutableArray *dotViewArray;
/// 圆点
@property (nonatomic, strong) NSMutableArray *dotPointArray;



# pragma mark - 内部配置相关
/// 内容宽度
@property (nonatomic, assign) CGFloat contentW;
/// 内容高度
@property (nonatomic, assign) CGFloat contentH;
/// 坐标点横向间距
@property (nonatomic, assign) CGFloat pointXSpace;
/// 虚线数量
@property (nonatomic, assign) CGFloat lineRow;
/// 记录Y轴0点的y坐标
@property (nonatomic, assign) CGFloat zeroY;
/// 手势开始触摸点
@property (nonatomic, assign) CGPoint gestureStartPoint;


/// 划线的起点
@property (nonatomic, assign) CGFloat startLayerX;
/// 划线的区域宽度
@property (nonatomic, assign) CGFloat startLayerW;
/// 左侧label宽度
@property (nonatomic, assign) CGFloat labelWidth;
/// 左侧label高度
@property (nonatomic, assign) CGFloat labelHeight;


/// 重置图表
-(void)resetChart;
/// 隐藏指示器竖线
-(void)hiddenMarkerLine;
/// 检查校验数据结构是否有误
-(BOOL)checkChartData;
/// 绘制图表
- (void)drawGraphViewUI;
/// 配置纵轴标题
-(void)setupYTitleWithChartUnit:(ChartUnitNum)chartUnit;
/// 配置浮窗和标线
-(void)setupMarkerViewAndLine;
/// 标线默认位置
-(void)defaultLinePlace;
/// 设置选中位置
-(void)changeSelectedWithIndex:(NSInteger)index;
/// 设置选中项
-(void)changeSelectedWithObject:(id)obj;
/// 处理横线区间行数和行间差值
-(void)handleHorizontalLineRowAndRelativeValue;
/// 获取纵轴Y坐标文本
-(NSArray *)getYLabelTextWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue smallRow:(NSInteger)smallRow bigRow:(NSInteger)bigRow lineRelativeValue:(double)lineRelativeValue leftY:(BOOL)leftY;
/// 获取纵坐标文本最大宽度
-(CGFloat)getMaxYLabelWidthWithTextArray:(NSArray *)textArray;
/// 获取横坐标文本最大宽度
-(CGFloat)getMaxXLabelWidthWithTextArray:(NSArray *)textArray;
/// 创建横坐标控件
-(void)creatXLabelWithXDataArray:(NSArray *)xDataArray barMargin:(CGFloat)barMargin;
/// 创建纵坐标控件和横虚线
-(void)creatYLabelAndDashLine;
@end

NS_ASSUME_NONNULL_END
