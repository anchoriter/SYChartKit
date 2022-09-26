//
//  SYChartMarkView.h
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import <UIKit/UIKit.h>
@class SYChartMarkItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface SYChartMarkView : UIView
/// 位置下标
@property (nonatomic, assign) NSInteger index;
/// 浮窗大小
@property (nonatomic, assign, readonly) CGSize markerSize;

/// 是否显示指定日期浮窗
@property (nonatomic, assign) BOOL showTopDateView;
/// 日期
@property (nonatomic, strong) NSString *dateStr;

/// 多行文案浮窗
@property (nonatomic, strong) NSArray <SYChartMarkItemModel *>*listArray;
@end

@interface SYChartMarkItemCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@end

@interface SYChartMarkItemModel : NSObject

@property (nonatomic, copy) NSString *leftText;
@property (nonatomic, copy) NSString *rightText;

@property (nonatomic, strong) NSMutableAttributedString *textAttr;
@end
NS_ASSUME_NONNULL_END
