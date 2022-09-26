//
//  SYSwitchView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYSwitchView.h"

@implementation SYSwitchView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.midSpace = 10;
        [self initSwitchSubviews];
        [self initConfig];
    }
    return self;
}
-(void)initConfig{
    self.onStatus = NO;
    self.lableWidth = 0;
    self.backgroundColor = [UIColor clearColor];
    
    self.switchLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    self.switchLabel.font = [UIFont systemFontOfSize:16];
}

-(void)initSwitchSubviews{
    UISwitch *switchBtn = [[UISwitch alloc] init];
    switchBtn.transform = CGAffineTransformMakeScale(0.65, 0.65);
    switchBtn.onTintColor = [UIColor colorWithHexString:@"#FC3737"];
    [self addSubview:switchBtn];
    self.switchBtn = switchBtn;
    switchBtn.userInteractionEnabled = NO;
    
    UILabel *switchLabel = [[UILabel alloc] init];
    [self addSubview:switchLabel];
    self.switchLabel = switchLabel;
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _Width = self.frame.size.width-self.lableWidth-self.midSpace;
    _Height = self.frame.size.height;
    if (self.switchLabelDirection == 1) {
        self.switchLabel.frame = CGRectMake(0, 0, self.lableWidth, _Height);
        self.switchBtn.frame = CGRectMake(self.lableWidth+self.midSpace, 0, _Width, _Height);
    }else {
        self.switchBtn.frame = CGRectMake(0, 0, _Width, _Height);
        self.switchLabel.frame = CGRectMake(_Width+self.midSpace, 0, self.lableWidth, _Height);
    }
    
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    self.onStatus = !self.onStatus;
    [self.switchBtn setOn:self.onStatus animated:YES];
    if(_changeBlock) _changeBlock(self.onStatus);
}
-(void)setOnStatus:(BOOL)onStatus{
    _onStatus = onStatus;
    [self.switchBtn setOn:onStatus animated:YES];
}

-(void)setSwitchLabelText:(NSString *)text{
    self.switchLabel.text = text;
}
- (void)setLableWidth:(CGFloat)lableWidth{
    _lableWidth = lableWidth;
    [self setNeedsLayout];
}
@end
