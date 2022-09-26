//
//  SYChartLegendExpandView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartLegendExpandView.h"
#import "SYChartBaseModel.h"

@interface SYChartLegendExpandView ()
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) SYChartBaseModel *chartModel;
/// 图例视图
@property (nonatomic, strong) NSArray *itemViewArray;

/// 一行几个(默认三个)
@property (nonatomic, assign) NSInteger columnNum;
@end
@implementation SYChartLegendExpandView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.columnNum = 3;
        [self creatExpandSubViews];
    }
    return self;
}
-(void)setLegendTitleArray:(NSArray *)titleArray colorArray:(NSArray *)colorArray itemSize:(CGSize)itemSize{
    
}
-(void)creatExpandSubViews{
    UIView *contentView = [[UIView alloc] init];
    contentView.layer.cornerRadius = 8*kScreenScale;
    contentView.layer.masksToBounds = YES;
    contentView.backgroundColor = [UIColor colorWithHexString:@"#F9FAFD"];
    [self addSubview:contentView];
    self.contentView = contentView;
}

/// 绑定数据
-(void)bindChartViewModel:(SYChartBaseModel *)chartModel{
    self.chartModel = chartModel;
    
    if (chartModel.chartOptions.legendColumnNum>0) {
        self.columnNum = chartModel.chartOptions.legendColumnNum;
    }
    
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[SYChartLegendExpandItemView class]]) {
            [v removeFromSuperview];
        }
    }
    
    NSMutableArray *columnMetas = self.chartModel.dataInfo.columnMetas.mutableCopy;
    if (chartModel.dataInfo.columnMetas.count>1) {
        [columnMetas removeObjectAtIndex:0];
        
        if (columnMetas.count>0) {
            NSMutableArray *itemViewArray = [NSMutableArray array];
            for (int i=0; i<columnMetas.count; i++) {
                SYChartLegendExpandItemView *itemView = [[SYChartLegendExpandItemView alloc] init];
                itemView.hidden = YES;
                [self.contentView addSubview:itemView];
                
                [itemViewArray addObject:itemView];
            }
            
            self.itemViewArray = itemViewArray.copy;
        }
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}
/// 选中某个数据时调用
-(void)showLegendDataWithIndex:(NSInteger)index{
    NSMutableArray *columnMetas = self.chartModel.dataInfo.columnMetas.mutableCopy;
    if (columnMetas.count>1) {
        [columnMetas removeObjectAtIndex:0];
        
        for (int i=0; i<columnMetas.count; i++) {
            SYChartColumnMetaModel *itemModel = columnMetas[i];
            if (itemModel && i < self.itemViewArray.count) {
                SYChartLegendExpandItemView *itemView = self.itemViewArray[i];
                if (itemView) {
                    itemView.colorView.backgroundColor = [UIColor colorWithHexString:itemModel.color];
                    itemView.titleLabel.text = itemModel.name;

                    itemView.hidden = NO;
                }
            }
        }
    }
    
    NSMutableArray *yArray = self.chartModel.dataInfo.datas.mutableCopy;
    if (yArray.count>1) {
        [yArray removeObjectAtIndex:0];// 排除X轴数据
        
        for (int i=0; i<yArray.count; i++) {
            NSString *leftValue = [self getItemValueWithArray:yArray[i] index:index];
            if (i < self.itemViewArray.count) {
                SYChartLegendExpandItemView *itemView = self.itemViewArray[i];
                if (itemView) {
                    itemView.valueLabel.text = leftValue;

                    itemView.hidden = NO;
                }
            }
        }
    }
}

-(NSString *)getItemValueWithArray:(NSArray *)array index:(NSInteger)index{
    if (index < array.count) {
        NSString *leftValue = [NSString stringWithFormat:@"%@", array[index]];
        return leftValue;
    }else{
        return @"";
    }
}

    
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(13*kScreenScale, 0, self.width-13*2*kScreenScale, self.height);
    
    CGFloat margin = 20*kScreenScale;
    if (self.columnNum>3) {
        margin = 13*kScreenScale;
    }
    CGFloat itemSpace = 0;
    
    // 注意：右侧仅为5
    CGFloat itemW = (self.contentView.width-margin-5*kScreenScale-itemSpace*(self.columnNum-1))/self.columnNum;
    CGFloat itemH = self.contentView.height;
    
    CGFloat topMargin = 0;
    
    if (itemH>0 && [self.itemViewArray count]>self.columnNum) {
        // 需要的行数
        NSInteger rowNum = (([self.itemViewArray count] - 1) / self.columnNum) + 1;
        
        if (rowNum>1) {
            topMargin = 10*kScreenScale;// 让内容更加内聚，减小行间距
            itemH = (self.contentView.height-topMargin*2)/rowNum;
        }
    }
    
    
    for (int i=0; i<self.itemViewArray.count; i++) {
        NSInteger row = i/self.columnNum;
        NSInteger column = i%self.columnNum;
        
        SYChartLegendExpandItemView *itemView = self.itemViewArray[i];
        itemView.frame = CGRectMake(margin+(itemW+itemSpace)*column, topMargin+itemH*row, itemW, itemH);
    }
}
@end



@interface SYChartLegendExpandItemView ()
 

@end

@implementation SYChartLegendExpandItemView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *colorView = [[UIView alloc] init];
        colorView.backgroundColor = [UIColor colorWithHexString:@"#FC3737"];
        colorView.layer.cornerRadius = 2;
        colorView.layer.masksToBounds = YES;
        [self addSubview:colorView];
        self.colorView = colorView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = kFontScale(12);
        titleLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = kFontNumberScale(12);
        valueLabel.textColor = [UIColor colorWithHexString:@"#222222"];
        [self addSubview:valueLabel];
        self.valueLabel = valueLabel;
        
        [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(titleLabel.mas_centerY);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(3);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(colorView.mas_right).offset(7);
            make.bottom.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(17);
        }];
        
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_left);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(4);
        }];
    }
    return self;
}
@end

