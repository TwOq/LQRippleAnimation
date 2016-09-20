//
//  ViewController.m
//  LQViewAnimation
//
//  Created by lizq on 16/9/19.
//  Copyright (c) 2016年 zqLee. All rights reserved.
//

#import "ViewController.h"
#import "UIView+RippleAnimation.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 300, 50)];
    testView.layer.borderColor = [UIColor blackColor].CGColor;
    testView.layer.borderWidth = 1;
    testView.layer.cornerRadius = 10;
    testView.backgroundColor = [UIColor orangeColor];
    testView.rippleAnimationEnable = YES;
    testView.rippleLayerColor = [UIColor redColor];
    testView.type = LQRippleAnimationTypeCenter;
    [self.view addSubview:testView];


    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 200, 300, 50);
    [button setTitle:@"122334456778" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 10;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.rippleAnimationEnable = YES;
    [self.view addSubview:button];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)buttonClick:(UIButton*)sender {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你好！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil ];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
