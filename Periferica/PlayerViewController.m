//
//  PlayerViewController.m
//  Periferica
//
//  Created by nifer on 4/24/15.
//  Copyright (c) 2015 lateralview. All rights reserved.
//

#import "PlayerViewController.h"
#import "Panframe/Panframe.h"
#import "UIImageView+AFNetworking.h"

@interface PlayerViewController ()<PFAssetObserver, PFAssetTimeMonitor>
{
    PFView * pfView;
    id<PFAsset> pfAsset;
    enum PFNAVIGATIONMODE currentmode;
    bool touchslider;
    NSTimer *slidertimer;
    int currentview;
    
    IBOutlet UIButton *playbutton;
    IBOutlet UIButton *stopbutton;
    IBOutlet UISlider *slider;
    IBOutlet UIButton *videoCloseButton;
    IBOutlet UIButton *photosCloseButton;
    IBOutlet UIButton *motionButton;
    
    IBOutlet UIActivityIndicatorView *seekindicator;
    
    NSTimer *bufferTimer;

}

- (void) onStatusMessage : (PFAsset *) asset message:(enum PFASSETMESSAGE) m;
- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time;

@end

@implementation PlayerViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    slider.value = 0;
    slider.enabled = false;

    slidertimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                   target: self
                                                 selector:@selector(onPlaybackTime:)
                                                 userInfo: nil repeats:YES];
  
  
  
    seekindicator.hidden = TRUE;
    
    currentmode = PF_NAVIGATION_MOTION;
    currentview = 0;

    [self normalButton:motionButton];
    [self normalButton:playbutton];
    [self normalButton:stopbutton];
  
    
    if (!self.isCredits) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }else{
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
    
    if (!_item.isVideo){
        playbutton.hidden = TRUE;
        stopbutton.hidden = TRUE;
        slider.hidden = TRUE;
        videoCloseButton.hidden = TRUE;
        photosCloseButton.hidden = FALSE;
    }else{
      if (!self.isPortrait) {
        videoCloseButton.hidden = FALSE;
        photosCloseButton.hidden = TRUE;
      }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isCredits) {
        [self setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
    }else{
        [self setOrientation:UIInterfaceOrientationMaskPortrait];
    }
    [self playButton:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [slidertimer invalidate];

    slidertimer = nil;
    [self stop];
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    // ATTENTION! Only return orientation MASK values
    return UIInterfaceOrientationMaskLandscapeLeft;
}



-(void)onPlaybackTime:(NSTimer *)timer
{
    // retrieve the playback time from an asset and update the slider
    
    if (pfAsset == nil)
        return;
        
    if (!touchslider && [pfAsset getStatus] != PF_ASSET_SEEKING)
    {
      if (!self.isPortrait) {
        CMTime t = [pfAsset getPlaybackTime];
        slider.value = CMTimeGetSeconds(t);
      }
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self resetViewParameters];
}

- (void) resetViewParameters
{
    // set default FOV(Field Of View)视场角定义:是指镜头能拍摄到的最大视场范围。
    [pfView setFieldOfView:75.0f];
    // register the interface orientation with the PFView
    [pfView setInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    switch([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            // Wider FOV which for portrait modes (matter of taste)
            [pfView setFieldOfView:90.0f];
            break;
        default:
            break;
    }
}

//- (void) createHotspots // BORRAR!
//{
//    // create some sample hotspots on the view and register a callback
//    
//    id<PFHotspot> hp1 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
//    id<PFHotspot> hp2 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
//    id<PFHotspot> hp3 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
//    id<PFHotspot> hp4 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
//    id<PFHotspot> hp5 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
//    id<PFHotspot> hp6 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
//    
//    [hp1 setCoordinates:0 andX:0 andZ:0];
//    [hp2 setCoordinates:40 andX:5 andZ:0];
//    [hp3 setCoordinates:80 andX:1 andZ:0];
//    [hp4 setCoordinates:120 andX:-5 andZ:0];
//    [hp5 setCoordinates:160 andX:-10 andZ:0];
//    [hp6 setCoordinates:220 andX:0 andZ:0];
//    
//    [hp3 setSize:2];
//    [hp3 setAlpha:0.5f];
//    
//    [hp1 setTag:1];
//    [hp2 setTag:2];
//    [hp3 setTag:3];
//    [hp4 setTag:4];
//    [hp5 setTag:5];
//    [hp6 setTag:6];
//    
//    [hp1 addTarget:self action:@selector(onHotspot:)];
//    [hp2 addTarget:self action:@selector(onHotspot:)];
//    [hp3 addTarget:self action:@selector(onHotspot:)];
//    [hp4 addTarget:self action:@selector(onHotspot:)];
//    [hp5 addTarget:self action:@selector(onHotspot:)];
//    [hp6 addTarget:self action:@selector(onHotspot:)];
//}

- (void) onHotspot:(id<PFHotspot>) hotspot
{
    // log the hotspot triggered
    NSLog(@"Hotspot triggered. Tag: %d", [hotspot getTag]);
    
    // animate the hotspot to show the user it was clicked
    [hotspot animate];
}

- (void) createView
{
    // initialize an PFView
    pfView = [PFObjectFactory viewWithFrame:[self.view bounds]];
    pfView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // set the appropriate navigation mode PFView
    [pfView setNavigationMode:currentmode];
    
    // set an optional blackspot image
    [pfView setBlindSpotImage:@"blackspot.png"];
    [pfView setBlindSpotLocation:PF_BLINDSPOT_BOTTOM];
    
    // add the view to the current stack of views
    [self.view addSubview:pfView];
    [self.view sendSubviewToBack:pfView];
    
    if (_cardboard)
        [pfView setViewMode:3 andAspect:16.0/9.0];//side-by-side VR 屏幕比例16:9
    else
        [pfView setViewMode:0 andAspect:16.0/9.0];//3D 屏幕比例16:9
    
    // Set some parameters
    [self resetViewParameters];
    
    // start rendering the view
    [pfView run];
    
}


- (void) deleteView
{
    // stop rendering the view
    [pfView halt];
    
    // remove and destroy view
    [pfView removeFromSuperview];
    pfView = nil;
}

- (void) createAssetWithUrl:(NSURL *)url
{
    touchslider = false;
    
    // load an PFAsset from an url
    pfAsset = (id<PFAsset>)[PFObjectFactory assetFromUrl:url observer:(PFAssetObserver*)self];
    [pfAsset setTimeMonitor:self];
    // connect the asset to the view
    [pfView displayAsset:(PFAsset *)pfAsset];
}

- (void) deleteAsset
{
    if (pfAsset == nil)
        return;
    
    // disconnect the asset from the view
    [pfAsset setTimeMonitor:nil];
    [pfView displayAsset:nil];
    // stop and destroy the asset
    [pfAsset stop];
    pfAsset  = nil;
}



- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time
{
  NSLog(@"%@",asset);
}

- (void) onStatusMessage : (id<PFAsset>) asset message:(enum PFASSETMESSAGE) m
{
    switch (m) {
        case PF_ASSET_SEEKING:
            NSLog(@"Seeking");
            seekindicator.hidden = FALSE;
            break;
        case PF_ASSET_PLAYING:
            NSLog(@"Playing");
            seekindicator.hidden = TRUE;
            CMTime t = [asset getDuration];
            slider.maximumValue = CMTimeGetSeconds(t);
            slider.minimumValue = 0.0;
            [playbutton setTitle:@"Play" forState:UIControlStateNormal];
            slider.enabled = true;
            break;
        case PF_ASSET_PAUSED:
            NSLog(@"Paused");
            [playbutton setTitle:@"Pause" forState:UIControlStateNormal];
            break;
        case PF_ASSET_COMPLETE:
            NSLog(@"Complete");
            [asset setTimeRange:CMTimeMakeWithSeconds(0, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
            break;
        case PF_ASSET_STOPPED:
            NSLog(@"Stopped");
            [self stop];
            slider.value = 0;
            slider.enabled = false;
            break;
        default:
            break;
    }
}


- (void) stop
{
    // stop the view
    [pfView halt];
    
    // delete asset and view
    [self deleteAsset];
    [self deleteView];
    
    [playbutton setTitle:@"Pause" forState:UIControlStateNormal];
}



- (IBAction) stopButton:(id) sender
{
    [self normalButton:sender];
    /*
     if (pfAsset == nil)
     return;
     */
    [self stop];
}

- (IBAction) playButton:(id) sender
{
    [self normalButton:sender];
    
    if (pfAsset != nil)
    {
        [pfAsset pause];
        return;
    }
    
    // create a Panframe view
    [self createView];
    
    // create some hotspots
//     [self createHotspots];

    
    // create a Panframe asset
    if (self.isCredits){
        [self createAssetWithUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"loop_piso" ofType:@"mp4"]]];
    }else if (_item.isVideo)
        [self createAssetWithUrl:[NSURL URLWithString:_item.url]];
    else {
        if (_item.url != nil){
            seekindicator.hidden = FALSE;
            dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void)
                           {
                               NSURL *thumbnailUrl = [NSURL URLWithString:_item.url];
                               NSData * data = [[NSData alloc] initWithContentsOfURL:thumbnailUrl];
                               UIImage * image = [[UIImage alloc] initWithData:data];
                               dispatch_async( dispatch_get_main_queue(), ^(void){
                                   seekindicator.hidden = TRUE;
                                   if( image != nil )
                                   {
                                       [pfView injectImage:image];
                                   } else {
                                       //error
                                   }
                               });
                           });
        }
    }
    
    if ([pfAsset getStatus] == PF_ASSET_ERROR)
        [self stop];
    else
        [pfAsset play];
}

- (IBAction) toggleNavigation:(id) sender
{
    if (pfView != nil)
    {
        if (currentmode == PF_NAVIGATION_MOTION)
        {
            currentmode = PF_NAVIGATION_TOUCH;
            [motionButton setTitle:@"Touch" forState:UIControlStateNormal];
        }
        else
        {
            currentmode = PF_NAVIGATION_MOTION;
            [motionButton setTitle:@"Motion" forState:UIControlStateNormal];
        }
        [pfView setNavigationMode:currentmode];
    }
    
    [self normalButton:motionButton];
}



- (IBAction) hiliteButton:(id) sender//深蓝色
{
    UIButton *b = (UIButton *) sender;
    b.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:72.0/255.0 blue:160.0/255.0 alpha:1.0];
}

- (IBAction) normalButton:(id) sender//灰色
{
    UIButton *b = (UIButton *) sender;
    b.backgroundColor = [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1.0];
}

- (IBAction) close {
  [self stop];
  if (_cardboard){
    _cardboardVC.cameFromPlayer = YES;
  }
  //Set Portrait
  NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
  [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
  [self setOrientation:UIInterfaceOrientationMaskPortrait];
  [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)sliderChanged:(id) sender
{
  
}

- (IBAction)sliderUp:(id) sender
{
    if (pfAsset != nil)
        [pfAsset setTimeRange:CMTimeMakeWithSeconds(slider.value, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
    touchslider = false;
}

- (IBAction) sliderDown:(id) sender
{
    touchslider = true;
}


@end
