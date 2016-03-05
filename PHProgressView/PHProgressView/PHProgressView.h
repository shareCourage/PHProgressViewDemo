//
//  PHProgressView.h
//  PHProgressView
//
//  Created by Kowloon on 16/3/5.
//  Copyright © 2016年 PaulCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHProgressView : UIView

@property (nonatomic, strong) UIColor *progressTintColor;

@property (nonatomic, assign) CGFloat progress;



- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
