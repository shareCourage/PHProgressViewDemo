//
//  PHProgressView.m
//  PHProgressView
//
//  Created by Kowloon on 16/3/5.
//  Copyright © 2016年 PaulCompany. All rights reserved.
//

#define PHCGColorWithAlpha(kColor,alpha) [kColor colorWithAlphaComponent:alpha].CGColor
#define PHCGColor(kColor) PHCGColorWithAlpha(kColor,0.6f)
#define PHProgress(progress) (M_PI * 2 * progress)

#import "PHProgressView.h"

static const CGFloat outSideWidth = 5.f;
static const CGFloat padding = 10.f;
static const CGFloat animationDuration = 1.f;
static const NSInteger maxTotalPathNumber = 60;
static const NSInteger minTotalPathNumber = 5;

@interface PHProgressView ()

@property (nonatomic, strong) CAShapeLayer *outSideCircleLayer;
@property (nonatomic, strong) UIBezierPath *outSidePath;

@property (nonatomic, strong) CAShapeLayer *insideCircleLayer;
@property (nonatomic, strong) UIBezierPath *inSidePath;

@property (nonatomic, assign) CGPoint selfCenter;
@property (nonatomic, assign) CGFloat outSideRadius;
@property (nonatomic, assign) CGFloat insideRadius;

@property (nonatomic, strong) NSMutableArray *paths;
@end

@implementation PHProgressView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.outSideRadius = width > height ? height : width;
        self.selfCenter = CGPointMake(width / 2, height / 2);
        [self.outSidePath addArcWithCenter:self.selfCenter radius:self.outSideRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        self.outSideCircleLayer.path = self.outSidePath.CGPath;
        [self.layer addSublayer:self.outSideCircleLayer];
        
        self.insideRadius = self.outSideRadius - padding;
//        [self.inSidePath addArcWithCenter:self.selfCenter radius:self.insideRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
//        self.insideCircleLayer.path = self.inSidePath.CGPath;
        [self.layer addSublayer:self.insideCircleLayer];
    }//UIProgressView;
    return self;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.outSideCircleLayer.strokeColor = PHCGColor(progressTintColor);
    self.insideCircleLayer.fillColor = PHCGColor(progressTintColor);
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self.inSidePath removeAllPoints];
    if (progress <= 0) {
        progress = 0.f;
    } else if (progress >= 1) {
        progress = 1.f;
    }
    CGFloat endAngle = PHProgress(progress);
    [self.inSidePath moveToPoint:self.selfCenter];
    [self.inSidePath addArcWithCenter:self.selfCenter radius:self.insideRadius startAngle:0 endAngle:endAngle clockwise:YES];
    [self.inSidePath closePath];
    self.insideCircleLayer.path = self.inSidePath.CGPath;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (!animated) {
        [self setProgress:progress];
        return;
    } else {
        _progress = progress;
        if (progress <= 0) return;
        progress = progress > 1 ? 1 : progress;
        CGFloat endAngle = PHProgress(progress);
        [self.inSidePath removeAllPoints];
        NSArray *paths = [self pathsWithProgress:progress finalAngle:endAngle];
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        pathAnimation.delegate = self;
        [pathAnimation setValues:paths];
        [pathAnimation setDuration:animationDuration];
        [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [pathAnimation setFillMode:kCAFillModeForwards];
        [pathAnimation setRemovedOnCompletion:NO];
        [self.insideCircleLayer addAnimation:pathAnimation forKey:@"path"];
        
    }
}

- (NSArray *)pathsWithProgress:(CGFloat)progress finalAngle:(CGFloat)finalAngle {
    NSInteger num = progress * maxTotalPathNumber;
    num = num > minTotalPathNumber ? num : minTotalPathNumber;
    NSLog(@"num, %@", @(num));
    CGFloat value = finalAngle / num;//把整个弧度划分成num块
    for (NSUInteger index = 0; index < num; index ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGFloat startAng = 0;//每个路径的开始角度都不一样
        CGFloat endAng = (index + 1) * value;
        [path moveToPoint:self.selfCenter];
        [path addArcWithCenter:self.selfCenter radius:self.insideRadius startAngle:startAng endAngle:endAng clockwise:YES];
        [path closePath];
        [self.paths addObject:(id)path.CGPath];
    }
    return [self.paths copy];
}

#pragma mark - AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"%s",__func__);
    id path = [self.paths lastObject];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.insideCircleLayer.path = (__bridge CGPathRef _Nullable)(path);
    [CATransaction commit];
    [self.paths removeAllObjects];
}


#pragma mark - lazy loading
- (NSMutableArray *)paths {
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}

- (CAShapeLayer *)outSideCircleLayer {
    if (!_outSideCircleLayer) {
        _outSideCircleLayer = [CAShapeLayer layer];
        _outSideCircleLayer.strokeColor = PHCGColor([UIColor whiteColor]);
        _outSideCircleLayer.fillColor = PHCGColor([UIColor lightGrayColor]);
        _outSideCircleLayer.lineCap = kCAFillRuleNonZero;
        _outSideCircleLayer.lineWidth = outSideWidth;
        _outSideCircleLayer.strokeStart = 0.f;
        _outSideCircleLayer.strokeEnd = 1.f;
    }
    return _outSideCircleLayer;
}

- (CAShapeLayer *)insideCircleLayer {
    if (!_insideCircleLayer) {
        _insideCircleLayer = [CAShapeLayer layer];
        _insideCircleLayer.strokeColor = [UIColor clearColor].CGColor;
        _insideCircleLayer.fillColor = PHCGColor([UIColor whiteColor]);
        _insideCircleLayer.lineCap = kCALineCapSquare;
        _insideCircleLayer.lineWidth = .1f;
        _insideCircleLayer.strokeStart = 0.f;
        _insideCircleLayer.strokeEnd = 1.f;
    }
    return _insideCircleLayer;
}

- (UIBezierPath *)outSidePath {
    if (!_outSidePath) {
        _outSidePath = [UIBezierPath bezierPath];
    }
    return _outSidePath;
}

- (UIBezierPath *)inSidePath {
    if (!_inSidePath) {
        _inSidePath = [UIBezierPath bezierPath];
    }
    return _inSidePath;
}

@end
