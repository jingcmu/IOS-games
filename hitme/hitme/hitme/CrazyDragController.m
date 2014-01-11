//
//  CrazyDragController.m
//  hitme
//
//  Created by 陈 靖 on 14-1-8.
//  Copyright (c) 2014年 US Asia Internet. All rights reserved.
//

#import "CrazyDragController.h"

@interface CrazyDragController () {
    int currentValue;
}
- (IBAction)showAlert:(id)sender;
- (IBAction)sliderMoved:(id)sender;

@end

@implementation CrazyDragController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAlert:(id)sender {
    [[[UIAlertView alloc]initWithTitle:@"你好，苍老师"
      message:@"听说您的新贴转发了499次"
      delegate:nil
      cancelButtonTitle:@"我来帮转1次，你懂的"
      otherButtonTitles:nil,
      nil]show];
}

- (IBAction)sliderMoved:(id)sender {
    UISlider *slider = (UISlider*)sender;
    currentValue = lroundf(slider.value);
}
@end
