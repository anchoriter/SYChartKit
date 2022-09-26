//
//  SYSwitchView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^SwitchBlock) (BOOL OnStatus);

@interface SYSwitchView : UIView
/// 开关
@property (nonatomic, strong) UISwitch *switchBtn;
/// 右侧文字
@property (nonatomic, strong) UILabel *switchLabel;

/// switchLabel 位置方向  默认右侧  0：右侧 1：左侧
@property (nonatomic,assign)NSInteger switchLabelDirection;

/// Switch 文字宽
@property (nonatomic, assign) CGFloat lableWidth;
/// 开关和文字间距
@property (nonatomic, assign) CGFloat midSpace;
/// Switch 宽
@property (nonatomic, assign) CGFloat Width;
/// Switch 高
@property (nonatomic, assign) CGFloat Height;

/// Switch 返回开关量block
@property (nonatomic, copy) SwitchBlock changeBlock;
/// Switch 开关状态
@property (nonatomic, assign) BOOL onStatus;

/// 设置开关文字
-(void)setSwitchLabelText:(NSString *)text;
/// 设置开关文本宽度
- (void)setLableWidth:(CGFloat)lableWidth;
@end

NS_ASSUME_NONNULL_END
