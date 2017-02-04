//
//  MLWViewController.m
//  Overlap
//
//  Created by Anton Bukov on 05/10/2016.
//  Copyright (c) 2016 Anton Bukov. All rights reserved.
//

#import <Overlap/Overlap.h>

#import "MLWViewController.h"

@interface MLWViewController ()

@property (strong, nonatomic) IBOutlet UIView *leftPanView;
@property (strong, nonatomic) IBOutlet UIView *rightPanView;

@property (strong, nonatomic) MLWOverlapView *overlapView;

@end

@implementation MLWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.overlapView = [[MLWOverlapView alloc] initWithOverlapsCount:4 generator:^__kindof UIView *(NSUInteger overlapIndex) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Some cool text";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:32.0];
        if (overlapIndex == 0) {
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
        } else if (overlapIndex == 1) {
            label.textColor = [UIColor blueColor];
            label.backgroundColor = [UIColor clearColor];
        } else if (overlapIndex == 2) {
            label.textColor = [UIColor redColor];
            label.backgroundColor = [UIColor clearColor];
        } else if (overlapIndex == 3) {
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor whiteColor];
        }
        return label;
    }];
    [self.view addSubview:self.overlapView];
    self.overlapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.overlapView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.overlapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.overlapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.overlapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    [self.leftPanView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    [self.rightPanView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self pan:nil];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer) {
        CGPoint point = [recognizer translationInView:self.view];

        if (recognizer.state == UIGestureRecognizerStateChanged) {
            recognizer.view.transform = CGAffineTransformMakeTranslation(point.x, point.y);
        }

        if (recognizer.state == UIGestureRecognizerStateEnded) {
            recognizer.view.transform = CGAffineTransformIdentity;
        }
    }
    
    UIBezierPath *fullPath = [UIBezierPath bezierPathWithRect:self.overlapView.bounds];
    UIBezierPath *leftFullPath = [UIBezierPath bezierPathWithRect:[self.leftPanView convertRect:self.leftPanView.bounds toView:self.overlapView]];
    UIBezierPath *rightFullPath = [UIBezierPath bezierPathWithRoundedRect:[self.rightPanView convertRect:self.rightPanView.bounds toView:self.overlapView] cornerRadius:self.rightPanView.layer.cornerRadius];
    
    UIBezierPath *commonPath = [fullPath copy];
    commonPath.usesEvenOddFillRule = YES;
    [commonPath appendPath:rightFullPath.bezierPathByReversingPath];
    [commonPath appendPath:leftFullPath.bezierPathByReversingPath];
    commonPath = commonPath.bezierPathByReversingPath;
    
    UIBezierPath *leftPath = [fullPath copy];
    UIBezierPath *rightPath = [fullPath copy];
    leftPath.usesEvenOddFillRule = YES;
    rightPath.usesEvenOddFillRule = YES;
    [leftPath appendPath:rightFullPath.bezierPathByReversingPath];
    [rightPath appendPath:leftFullPath.bezierPathByReversingPath];
    
    [self.overlapView overlapWithViewPaths:@[
        [UIBezierPath bezierPathWithRect:self.overlapView.bounds],
        leftPath,
        rightPath,
        commonPath,
    ]];
}

@end
