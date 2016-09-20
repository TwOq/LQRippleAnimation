//
//  UIView+WaterAnimation.h
//  
//
//  Created by lizq on 16/9/19.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LQRippleAnimationTypes) {
    LQRippleAnimationTypeNormal = 0,
    LQRippleAnimationTypeCenter
};

@interface UIView (RippleAnimation)

//波纹效果是否可用
@property (nonatomic, assign) BOOL rippleAnimationEnable;
//波纹颜色
@property (nonatomic, strong) UIColor *rippleLayerColor;
//动画类型
@property (nonatomic, assign) LQRippleAnimationTypes type;

@end
