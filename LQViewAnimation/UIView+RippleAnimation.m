//
//  UIView+WaterAnimation.m
//  
//
//  Created by lizq on 16/9/19.
//
//

#import "UIView+RippleAnimation.h"
#import <objc/runtime.h>

#define WIDTH   self.bounds.size.width
#define HEGITH  self.bounds.size.height

static NSString *const animationKey         = @"rippleAnimationKey";
static NSString *const animationLayerKey    = @"rippleAnimationLayer";
static NSString *const animationTypeKey     = @"rippleanimationTypeKey";
static NSString *const rippleLayerColorKey  = @"rippleLayerColorKey";

static float  animationToValue;
static float  layerWith;
static BOOL   _isTapAnimation = NO;

@interface UIView ()
@property (nonatomic, strong) CALayer *animationLayer;
@end

@implementation UIView (RippleAnimation)

- (void)calculateAnimationValueFromPoint:(CGPoint)point {
    layerWith = 20;
    if (WIDTH > HEGITH) {
        animationToValue = MAX(WIDTH - point.x, point.x)/(layerWith/4);
    }else{
        animationToValue = MAX(HEGITH - point.y, point.y)/(layerWith/4);
    }
}

- (void)createLayerWithCenter:(CGPoint)center {
    CALayer *layer = [CALayer layer];
    layer.bounds = CGRectMake(0, 0, layerWith, layerWith);
    if (self.type == LQRippleAnimationTypeNormal) {
        layer.position = center;
    }else{
        layer.position = CGPointMake(center.x, HEGITH/2.0);
    }
    layer.backgroundColor = self.rippleLayerColor.CGColor;
    layer.cornerRadius = layerWith/2.0;
    layer.masksToBounds = YES;
    [self.layer addSublayer:layer];
    self.animationLayer = layer;
}

#pragma mark  手势处理

- (void)tapGestureHandle:(UIGestureRecognizer *)gesture {
    if (self.animationLayer) {
        return;
    }
    CGPoint point = [gesture locationInView:self];
    [self calculateAnimationValueFromPoint:point];
    [self createLayerWithCenter:point];
    [self scaleAnimationWithDuration:0.5 withName:@"TapGesture"];
}


- (void)longGestureHandle:(UIGestureRecognizer *)gesture {

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (_isTapAnimation) {
                return;
            }
            CGPoint point = [gesture locationInView:self];
            [self calculateAnimationValueFromPoint:point];
            [self createLayerWithCenter:point];
            [self scaleAnimationWithDuration:1.5 withName:@"LongGesture"];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (_isTapAnimation) {
                [self.animationLayer removeFromSuperlayer];
                self.animationLayer = nil;
                _isTapAnimation = NO;
            }else{
                _isTapAnimation = YES;
                [self.animationLayer setValue:@"stop" forKey:@"state"];
                self.animationLayer.speed = 1.0001;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            _isTapAnimation = YES;
            [self.animationLayer setValue:@"stop" forKey:@"state"];
            self.animationLayer.speed = 1.0001;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
            break;
    }
}

#pragma mark 动画设置

- (void)scaleAnimationWithDuration:(CGFloat)duration withName:(NSString *)name{

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = duration;
    animation.fromValue = @1;
    animation.toValue = [NSNumber numberWithFloat:animationToValue];
    animation.repeatCount = 0;
    animation.delegate = (id)self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [animation setValue:name forKey:@"name"];
    [self.animationLayer setValue:animation forKey:@"animation"];
    [self.animationLayer addAnimation:animation forKey:@"ripple"];
}

- (void)opacityAnimationWithDuration:(CGFloat)duration withName:(NSString *)name {
    _isTapAnimation = YES;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = duration;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.repeatCount = 0;
    animation.delegate = (id)self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [animation setValue:name forKey:@"name"];
    [self.animationLayer addAnimation:animation forKey:@"ripple"];
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {

    if ([[anim valueForKey:@"name"] isEqualToString:@"TapGesture"]) {
        self.animationLayer.transform = CATransform3DMakeScale(animationToValue, animationToValue, 1);
        [self opacityAnimationWithDuration:0.25 withName:@"opacity"];
    }else if ([[anim valueForKey:@"name"] isEqualToString:@"opacity"]){
        [self.animationLayer removeFromSuperlayer];
        self.animationLayer = nil;
        _isTapAnimation = NO;
    }else {
        _isTapAnimation = YES;
        if ([[self.animationLayer valueForKey:@"state"] isEqualToString:@"stop"]) {
            self.animationLayer.transform = CATransform3DMakeScale(animationToValue, animationToValue, 1);
            [self opacityAnimationWithDuration:0.25 withName:@"opacity"];
        }
    }
}

#pragma mark getter or setter

- (BOOL)rippleAnimationEnable {
    
    NSNumber *number = objc_getAssociatedObject(self, (__bridge const void *)(animationKey));
    return [number boolValue];
}

- (void)setRippleAnimationEnable:(BOOL)rippleAnimationEnable {
    objc_setAssociatedObject(self, (__bridge const void *)(animationKey), [NSNumber numberWithBool:rippleAnimationEnable], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (rippleAnimationEnable) {

        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureHandle:)];
        longPressGesture.minimumPressDuration = 0.5;
        longPressGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:longPressGesture];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
        [tapGesture requireGestureRecognizerToFail:longPressGesture];
        tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGesture];

        self.layer.masksToBounds = YES;
    }
}

- (CALayer *)animationLayer {
    return  objc_getAssociatedObject(self, (__bridge const void *)(animationLayerKey));
}

- (void)setAnimationLayer:(CALayer *)animationLayer {
    objc_setAssociatedObject(self, (__bridge const void *)(animationLayerKey), animationLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)rippleLayerColor {
    UIColor *color = objc_getAssociatedObject(self, (__bridge const void *)(rippleLayerColorKey));
    if (color) {
        return color;
    }
    return [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (void)setRippleLayerColor:(UIColor *)rippleLayerColor {
    objc_setAssociatedObject(self, (__bridge const void *)(rippleLayerColorKey), rippleLayerColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LQRippleAnimationTypes)type {
    NSNumber *number = objc_getAssociatedObject(self, (__bridge const void *)(animationTypeKey));
    return [number integerValue];
}
- (void)setType:(LQRippleAnimationTypes)type {
    objc_setAssociatedObject(self, (__bridge const void *)(animationTypeKey), [NSNumber numberWithInteger:type], OBJC_ASSOCIATION_ASSIGN);
}

@end
