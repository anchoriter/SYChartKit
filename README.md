# SYChartKit
# iOS 曲线折线图、双轴曲线图、柱状图、堆积图、瀑布图、散点图、气泡图、多柱曲线双轴图等

>不借助第三方框架，自己手动绘制图表（曲线图、折线图、双轴曲线图、柱状图、堆积图、瀑布图、散点图、气泡图）

![曲线图折线图](https://upload-images.jianshu.io/upload_images/2117012-7ed2a3c8c443ba5d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![双轴曲线图折线图](https://upload-images.jianshu.io/upload_images/2117012-72ec2c6b3151908b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![柱状图](https://upload-images.jianshu.io/upload_images/2117012-c3cfcc2a43edc4d0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![堆积图](https://upload-images.jianshu.io/upload_images/2117012-75fad7cb2d50cb43.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![散点图](https://upload-images.jianshu.io/upload_images/2117012-8fef9f2f7610bdaa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![气泡图](https://upload-images.jianshu.io/upload_images/2117012-527dd2dace08d1bc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#####一部分UI自定义属性
```
/// 图表类型
@property (nonatomic, assign) LBTChartType chartType;
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
/// 是否显示浮窗纵向虚线 默认NO
@property (nonatomic, assign) BOOL showMarkLine;
/// 是否初始选中数据
@property (nonatomic, assign) BOOL showSelected;
/// 是否显示mock数据 默认NO
@property (nonatomic, assign) BOOL showMock;
/// 图例位置 默认：None不展示
@property (nonatomic, assign) LBTChartLegendPosition legendPosition;
/// 图例类型
@property (nonatomic, assign) LBTChartLegendType legendType;
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
/// 开始点和结束点的缩进
@property (nonatomic, assign) CGFloat startPointPadding;
```
