//
//  ViewController.m
//  PHProgressView
//
//  Created by Kowloon on 16/3/1.
//  Copyright © 2016年 PaulCompany. All rights reserved.
//

#import "ViewController.h"
#import "PHProgressView.h"

@interface ViewController ()
{
    CGFloat value;
}

@property (nonatomic, weak) PHProgressView *progressView;

@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    PHProgressView *progressView = [[PHProgressView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    progressView.backgroundColor = [UIColor redColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    self.progressView.progress = 0;

}
- (IBAction)btnClick:(id)sender {
    value = value + 0.1;
    if (value >= 1) {
        value = 0.1;
        self.progressView.progress = 0;
    }
    NSLog(@"btnValue -> %@", @(value));
//    self.progressView.progress = value;
    if (value < self.progressView.progress) return;
    [self.mySlider setValue:value animated:YES];
    [self.progressView setProgress:value animated:YES];
}

- (IBAction)sliderClick:(UISlider *)sender {
    NSLog(@"%lf",sender.value);
    self.progressView.progress = sender.value;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.progressView.progressTintColor = [UIColor colorWithRed:arc4random_uniform(255)/255.f green:arc4random_uniform(255)/255.f blue:arc4random_uniform(255)/255.f alpha:1];
    
}

@end





