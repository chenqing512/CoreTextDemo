//
//  ViewController.m
//  CoreTextDemo
//
//  Created by ChenQing on 17/8/18.
//  Copyright © 2017年 ChenQing. All rights reserved.
//

#import "ViewController.h"
#import "XYCTView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XYCTView *view=[[XYCTView alloc]initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:view];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
