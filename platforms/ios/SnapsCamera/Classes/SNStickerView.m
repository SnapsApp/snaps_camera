//
//  SNStickerView.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/18/14.
//
//

#import "SNStickerView.h"
#import "UIImage+Resize.h"
#import "UIButton+Snaps.h"

@interface SNStickerView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *_close;
@property (nonatomic, strong) UIActivityIndicatorView *_loading;

@end

@implementation SNStickerView

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
        self.opaque = NO;
        
        self._close = [UIButton getButton:@"icon.close"];
        [self._close addTarget:self action:@selector(removeSticker:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self._close];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
        
        UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        rotate.delegate = self;
        [self addGestureRecognizer:rotate];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        if (!self.image) {
            self._close.hidden = YES;
            
            self._loading = [[UIActivityIndicatorView alloc] init];
            self._loading.opaque = NO;
            self._loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [self._loading startAnimating];
            [self addSubview:self._loading];
        }
    }
    
    return self;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self._close.frame, point)) {
        return YES;
    }
    
    return [super pointInside:point withEvent:event];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    [self.delegate selectSticker:self];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    [self.delegate selectSticker:self];
}

- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer
{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    [self.delegate selectSticker:self];
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer
{
    [self.delegate selectSticker:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
//    return ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) ||
//           ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]);
}

- (void)removeSticker:(id)sender
{
    [self.delegate removeSticker:self];
}

- (void)layoutSubviews
{
    CGFloat s = 32;
    self._close.frame = CGRectMake(self.bounds.size.width - s / 2, -s / 2, s, s);
}

- (void)setImage:(UIImage *)image
{
    self->_image = image;
    
    if (image) {
        [self._loading removeFromSuperview];
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.image) {
        [self.image drawInRect:self.bounds];
        
        BOOL selected = (self.delegate && [self.delegate isSelectedSticker:self]);
        self._close.hidden = !selected;
        
        if (selected) {
            CGContextSetLineWidth(context, 1.0);
            CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.5);
            CGContextStrokeRect(context, self.bounds);
        }
    }
}

@end
