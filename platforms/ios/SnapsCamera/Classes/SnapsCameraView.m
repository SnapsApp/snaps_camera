//
//  SnapsCameraView.m
//  SnapsCamera
//
//  Created by Travis Fischer on 8/6/14.
//
//

#import "SnapsCameraView.h"
#import "SnapsCamera.h"
#import "SNCameraButton.h"

#define IS_IPHONE_5  (([[UIScreen mainScreen] bounds].size.height >= 568) ? YES : NO)

@interface SnapsCameraView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *_overlay;
@property (nonatomic, strong) UIImagePickerController *_picker;

@end

@implementation SnapsCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self._picker = [[UIImagePickerController alloc] init];
        
        // Configure the UIImagePickerController instance
        self._picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self._picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self._picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self._picker.showsCameraControls = NO;
        
        self._picker.delegate = self;
        
        // Set the frames to be half screen
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        CGRect frame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height / 2);
        self.frame = frame;
        self._picker.view.frame = frame;
        
        self._overlay = [[UIView alloc] initWithFrame:frame];
        
        SNCameraButton *photoButton = [SNCameraButton new];
        CGFloat size = (IS_IPHONE_5 ? 60 : 45);
        photoButton.frame = CGRectMake(0, 0, size, size);
        photoButton.center = CGPointMake(frame.size.width / 2, frame.size.height - size / 2 - 8);
        [photoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self._overlay addSubview:photoButton];
        self._picker.cameraOverlayView = self._overlay;
        
        [self addSubview:self._picker.view];
    }
    
    return self;
}

- (void)takePhoto:(id)sender
{
    [self._picker takePicture];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = @"test.jpg";
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    [imageData writeToFile:imagePath atomically:YES];
    
    // Tell the plugin class that we're finished processing the image
    [self.plugin capturedImageWithPath:imagePath];
}

@end
