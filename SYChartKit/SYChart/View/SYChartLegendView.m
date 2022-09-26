//
//  SYChartLegendView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartLegendView.h"
#import "SYChartTool.h"
#import "SYColorButton.h"

@interface SYChartLegendView ()
 

@end
@implementation SYChartLegendView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)setLegendTitleArray:(NSArray *)titleArray colorArray:(NSArray *)colorArray itemSize:(CGSize)itemSize{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    if (titleArray.count == 0 || titleArray.count != colorArray.count) {
        return;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
    }];
    
    NSMutableArray *temArr = [NSMutableArray array];
    UIView *lastView = nil;
    for (int i=0; i<titleArray.count; i++) {
        NSString *title = titleArray[i];
        SYColorButton *legendButton = [[SYColorButton alloc] init];
        [legendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        legendButton.titleLabel.font = UIFontMake(12);
        [legendButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        [legendButton setTitle:title forState:UIControlStateNormal];
        
        CGSize imgSize = CGSizeMake(7, 7);
        if (!CGSizeEqualToSize(imgSize, CGSizeZero)) {
            imgSize = itemSize;
        }
        
        UIImage *img = nil;
        NSString *colorStr = colorArray[i];
        if (!KStringIsEmpty(colorStr)) {
            img = [SYChartTool imageWithColor:[UIColor clearColor] size:CGSizeMake(imgSize.width, imgSize.height) cornerRadius:0];
            
            legendButton.color = [UIColor colorWithHexString:colorStr];
            legendButton.colorView.layer.cornerRadius = imgSize.height*0.5;
            legendButton.colorView.layer.masksToBounds = YES;
        }else{
            img = [UIImage imageNamed:@"circle_point_gray"];
        }
        
        if (img) {
            [legendButton setImage:img forState:UIControlStateNormal];
        }
        
        [contentView addSubview:legendButton];
        
        [legendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            if (lastView) {
                make.left.mas_equalTo(lastView.mas_right).offset(20);
            }
        }];
        if (i == 0) {
            [legendButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
            }];
        }
        if (i == titleArray.count-1) {
            [legendButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-4);
            }];
        }

        lastView = legendButton;
        [temArr addObject:legendButton];
    }
//    if (temArr.count>0) {
////        [contentView mas_distributeSpacingHorizontallyWith:temArr];
//        [temArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:0 tailSpacing:0];
//        [temArr mas_makeConstraints:^(MASConstraintMaker *make) {
////            make.top.mas_equalTo(0);
//            make.top.bottom.mas_equalTo(0);
//        }];
//    }
}

/// 选中某个数据时调用
-(void)showLegendDataWithIndex:(NSInteger)index{
    
}
@end
