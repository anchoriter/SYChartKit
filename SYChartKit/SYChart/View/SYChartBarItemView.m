//
//  SYChartBarItemView.m
//  SYChartKit
//
//  Created by Anchoriter on 2022/9/22.
//

#import "SYChartBarItemView.h"


@interface SYChartBarItemView ()

@end
@implementation SYChartBarItemView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
-(void)setDatasArray:(NSArray<SYChartBarItemModel *> *)datasArray{
    _datasArray = datasArray;
    
    [self removeAllLayer];
    
    if (datasArray.count>0) {
        CGFloat end = self.height;
        for (int i=0; i<datasArray.count; i++) {
            SYChartBarItemModel *itemModel = datasArray[i];
            
//            CGFloat itemY = self.height * (1-itemModel.scale);
            CGFloat itemHeight = self.height * itemModel.scale;
            if (itemModel.isMoreBar) {
                CGFloat itemW = self.width/datasArray.count;
                UIBezierPath *itemPath = [UIBezierPath bezierPathWithRect:CGRectMake(itemW*i, end-itemHeight, itemW, itemHeight)];
                CAShapeLayer *itemLayer = [CAShapeLayer layer];
                itemLayer.lineCap = kCALineCapRound;
                itemLayer.path = itemPath.CGPath;
                itemLayer.fillColor = itemModel.color.CGColor;
                [self.layer addSublayer:itemLayer];
            }else{
                UIBezierPath *itemPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, end-itemHeight, self.width, itemHeight)];
                CAShapeLayer *itemLayer = [CAShapeLayer layer];
                itemLayer.lineCap = kCALineCapRound;
                itemLayer.path = itemPath.CGPath;
                itemLayer.fillColor = itemModel.color.CGColor;
                [self.layer addSublayer:itemLayer];
                
                end = end-itemHeight;
            }
        }
    }
}

/// 清除之前所有subLayers
- (void)removeAllLayer{
    NSArray *sublayers = [NSArray arrayWithArray:self.layer.sublayers];
    for (CALayer * layer in sublayers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
}

///**
// *  CAShapeLayer
// *
// *  @return CAShapeLayer
// */
//- (CAShapeLayer *)topShapeLayer {
//
//    CGFloat currentHeight = self.height * self.scale * self.separateScale;
//    CGFloat end = self.height * (1-self.scale);
//
//    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, end, self.frame.size.width, currentHeight)];
//
//
//    CAShapeLayer * layer = [CAShapeLayer layer];
//    layer.lineCap = kCALineCapRound;
//    layer.path = endPath.CGPath;
//    layer.fillColor = [UIColor colorWithHexString:@"#EB574E"].CGColor;
//
//    if (!self.isCloseAnima) {
//        CABasicAnimation * animation = [self animation];
//        [layer addAnimation:animation forKey:nil];
//    }
//
//    return layer;
//}
//
//- (CAShapeLayer *)bottomShapeLayer {
//
//    CGFloat currentHeight = self.height * self.scale *( 1 - self.separateScale);
//    CGFloat end = self.height - currentHeight;
//
//    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, end, self.frame.size.width, currentHeight)];
//
//    CAShapeLayer * layer = [CAShapeLayer layer];
//    layer.lineCap = kCALineCapRound;
//    layer.path = endPath.CGPath;
//    layer.fillColor = [UIColor colorWithHexString:@"#FF954F"].CGColor;
//
//    return layer;
//}
@end
