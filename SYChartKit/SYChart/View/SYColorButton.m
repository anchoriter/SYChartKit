//
//  SYColorButton.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYColorButton.h"

@implementation SYColorButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *colorView = [[UIView alloc] init];
        [self addSubview:colorView];
        self.colorView = colorView;
    }
    return self;
}
-(void)setColor:(UIColor *)color{
    _color = color;
    self.colorView.backgroundColor = color;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.colorView.frame = self.imageView.frame;
}
@end
