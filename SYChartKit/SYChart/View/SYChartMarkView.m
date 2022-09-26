//
//  SYChartMarkView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartMarkView.h"
#import "SYChartTool.h"

static CGFloat const kChartMark_textFontSize= 11;

@interface SYChartMarkView ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat kChartMark_Top;
    CGFloat kChartMark_bottom;
    CGFloat kChartMark_titleH;
    CGFloat kChartMark_cellH;
    CGFloat kChartMark_footerH;
    CGFloat kChartMark_left;
    CGFloat textFontSize;
}
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, assign) CGSize markerSize;

@property (nonatomic, strong) UITableView *listTableView;
//@property (nonatomic, strong) NSMutableArray *listArray;
@end
@implementation SYChartMarkView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
        
        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowRadius = 6;
        self.layer.cornerRadius = 4;
        
//        [self configureUI];
        self.markerSize = CGSizeZero;
        kChartMark_cellH = 19;
        kChartMark_footerH = 0.1;
        
        kChartMark_Top = 0;
        kChartMark_bottom = 0;
        kChartMark_titleH = 18;
        kChartMark_left = 3;
        
        [self configureUI];
    }
    return self;
}
- (void)configureUI {
    [self addSubview:self.dateLabel];
    [self addSubview:self.listTableView];
}
-(void)setShowTopDateView:(BOOL)showTopDateView{
    _showTopDateView = showTopDateView;
    if (showTopDateView) {
        self.dateLabel.textColor = [UIColor colorWithHexString:@"#787878"];
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    }
    [self calculateGraphMarkHeight];
}

-(void)setDateStr:(NSString *)dateStr{
    _dateStr = dateStr;
    self.markerSize = CGSizeZero;
    
    if (KStringIsEmpty(dateStr)) {
        self.dateLabel.text = @"";
    }else{
        self.dateLabel.text = dateStr;
    }
    
    [self calculateGraphMarkHeight];
}
-(void)setListArray:(NSArray <SYChartMarkItemModel *>*)listArray{
    _listArray = listArray;
    
    kChartMark_Top = 9;
    kChartMark_left = 9;
    kChartMark_bottom = 9;
    kChartMark_titleH = 19;
    kChartMark_cellH = 19;
    kChartMark_footerH = 0.1;
    
    self.dateLabel.textColor = [UIColor whiteColor];
    
    if (listArray.count>0) {
        self.listTableView.hidden = NO;
    }else{
        self.listTableView.hidden = YES;
    }
    [self calculateGraphMarkHeight];
    
    [self.listTableView reloadData];
}

-(void)calculateGraphMarkHeight{
    CGFloat h = kChartMark_Top+kChartMark_bottom;
    CGFloat w = 0;
    if (!KStringIsEmpty(self.dateStr)) {
        h = h+kChartMark_titleH;
        w = [SYChartTool sizeWithString:self.dateStr font:kFontScale(kChartMark_textFontSize) maxSize:CGSizeMake(KWidth, kChartMark_titleH)].width;
        
        w = w+kChartMark_left*2;
    }
    
    if (self.listArray.count>0) {
        h = h+kChartMark_footerH+kChartMark_cellH*self.listArray.count;
        CGFloat cellWidth = 0;
        
        for (SYChartMarkItemModel *itemModel in self.listArray) {
            NSString *str = itemModel.leftText;
            if (!KStringIsEmpty(str)) {
                str = [str stringByAppendingString:@"："];
            }
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
            [attr addAttribute:NSFontAttributeName value:kFontScale(kChartMark_textFontSize) range:NSMakeRange(0, attr.length)];
            
            
            if (!KStringIsEmpty(itemModel.rightText)) {
                NSMutableAttributedString *rightAttr = [[NSMutableAttributedString alloc] initWithString:itemModel.rightText];
                [rightAttr addAttribute:NSFontAttributeName value:kFontNumberScale(kChartMark_textFontSize) range:NSMakeRange(0, rightAttr.length)];
                
                [attr appendAttributedString:rightAttr];
            }
            
            [attr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attr.length)];
            
            itemModel.textAttr = attr;
            
            if (!KStringIsEmpty(attr.string)) {
                CGSize temSize = [SYChartTool getSizeToAttributedString:attr RectWithSize:CGSizeMake(CGFLOAT_MAX, kChartMark_cellH)];
                CGFloat temW = temSize.width+kChartMark_left*2;
                if (temW > cellWidth) {
                    cellWidth = temW;
                }
            }
        }
        
        if (cellWidth>w) {
            w = cellWidth;
        }
    }
    
    self.markerSize = CGSizeMake(w, h);
}

-(void)layoutSubviews{
    [super layoutSubviews];

    self.dateLabel.frame = CGRectMake(kChartMark_left, kChartMark_Top, self.width-kChartMark_left*2, kChartMark_titleH);
    
    self.listTableView.frame = CGRectMake(kChartMark_left, self.dateLabel.bottom, self.width-kChartMark_left*2, self.height-self.dateLabel.bottom);
}

# pragma mark - UITableViewDelegate & UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return kChartMark_footerH;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SYChartMarkViewFooterViewIdentifier"];
    if (footerView == nil) {
        footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"SYChartMarkViewFooterViewIdentifier"];
        footerView.contentView.backgroundColor = [UIColor clearColor];
    }
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kChartMark_cellH;
}
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYChartMarkItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SYChartMarkItemCellIdentifier"];
    if (cell == nil){
        cell = [[SYChartMarkItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SYChartMarkItemCellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }

    if (indexPath.row < self.listArray.count) {
        SYChartMarkItemModel *itemModel = [self.listArray objectAtIndex:indexPath.row];
        cell.titleLabel.attributedText = itemModel.textAttr;
    }

    return cell;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:UIButton.class]) {
        return view;
    }
    return nil;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = kFontScale(kChartMark_textFontSize);
        _dateLabel.textColor = [UIColor colorWithHexString:@"#787878"];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _dateLabel;
}
-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.rowHeight = UITableViewAutomaticDimension;
        _listTableView.estimatedRowHeight = 20;
        _listTableView.estimatedSectionHeaderHeight = 0;
        _listTableView.estimatedSectionFooterHeight = 0;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTableView.backgroundColor = [UIColor clearColor];
        _listTableView.hidden = YES;

#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    return _listTableView;
}
@end


@interface SYChartMarkItemCell ()

@end
@implementation SYChartMarkItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = kFontScale(kChartMark_textFontSize);
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
       
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
        }];
    }
    return self;
}
@end

@interface SYChartMarkItemModel ()

@end
@implementation SYChartMarkItemModel


@end
