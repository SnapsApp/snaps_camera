//
//  SNCameraButton.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import "SNCameraButton.h"

@implementation SNCameraButton

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat a = 0.95;
    CGFloat b = 0.65;
    
    if (self.highlighted) {
        CGContextSetRGBStrokeColor(context, b, b, b, 1.0);
        
        CGContextSetRGBFillColor(context, 11.0/255.0, 61.0/255.0, 102.0/255.0, 1.0);
    } else {
        CGContextSetRGBStrokeColor(context, a, a, a, 1.0);
        
        CGContextSetRGBFillColor(context, 55.0/255.0, 154.0/255.0, 234.0/255.0, 1.0);
    }
    
    CGContextSetLineWidth(context, self.bounds.size.width / 40.0);
    CGContextFillEllipseInRect(context, CGRectInset(self.bounds, 5, 5));
    CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, 2, 2));
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self setNeedsDisplay];
    [super setHighlighted:highlighted];
}

@end
