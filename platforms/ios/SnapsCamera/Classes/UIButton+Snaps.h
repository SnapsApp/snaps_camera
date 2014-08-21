//
//  UIButton+Snaps.h
//  SnapsCamera
//
//  Created by Travis Fischer on 8/18/14.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (Snaps)

@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

+ (UIButton*)getButton:(NSString*)image;

- (void)setImage:(NSString*)image;

@end
