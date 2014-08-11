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
#import "UIImage+Resize.h"

#define IS_IPHONE_5  (([[UIScreen mainScreen] bounds].size.height >= 568) ? YES : NO)

@interface SnapsCameraView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *_overlay;
@property (nonatomic, strong) UIImagePickerController *_picker;
@property (nonatomic) NSInteger _offset;

@end

@implementation SnapsCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self._offset = 0;
        self._picker = [[UIImagePickerController alloc] init];
        
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
        NSLog(@"%f, %f", frame.size.width, frame.size.height);
        
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

- (void)openGallery:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    [self.plugin.viewController presentViewController:picker animated:YES completion:nil];
}

- (void)switchCameras:(id)sender
{
    if (self._picker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self._picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        self._picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image imageByScalingAndCroppingForSize:self.frame.size];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"snap-%ld.jpg", self._offset++];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [imageData writeToFile:imagePath atomically:YES];
    
    // Tell the plugin class that we're finished processing the image
    [self.plugin capturedImageWithPath:imagePath];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.plugin.viewController dismissViewControllerAnimated:YES completion:^{ }];
}

@end
