//
//  UIButton+Snaps.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/18/14.
//
//

#import "UIButton+Snaps.h"
#import "UIImage+Resize.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation UIButton (Snaps)

static const NSString *KEY_HIT_TEST_EDGE_INSETS = @"HitTestEdgeInsets";

-(void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets
{
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIEdgeInsets)hitTestEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS);
    
    if (value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets]; return edgeInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

+ (UIButton*)getButton:(NSString*)image
{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:image];
    button.hitTestEdgeInsets = UIEdgeInsetsMake(-16, -16, -16, -16);
    return button;
}

- (void)setImage:(NSString*)image
{
    [self setImage:[self getIcon:image] forState:UIControlStateNormal];
    [self setImage:[self getHighlightedIcon:image] forState:UIControlStateHighlighted];
    [self setImage:[self getSelectedIcon:image] forState:UIControlStateSelected];
}

- (UIImage*)getIcon:(NSString*)name
{
    UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
    UIColor *buttonColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    
    return [icon maskWithColor:buttonColor];
}

- (UIImage*)getHighlightedIcon:(NSString*)name
{
    UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
    UIColor *buttonColor = [UIColor colorWithRed:55.0/255.0 green:154.0/255.0 blue:234.0/255.0 alpha:1.0];
    
    return [icon maskWithColor:buttonColor];
}

- (UIImage*)getSelectedIcon:(NSString*)name
{
    UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
    UIColor *buttonColor = [UIColor colorWithRed:55.0/255.0 green:154.0/255.0 blue:234.0/255.0 alpha:1.0];
    
    return [icon maskWithColor:buttonColor];
}

@end
