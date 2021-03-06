//
//  CreditsVC.m
//  Periferica
//
//  Created by fede on 4/27/15.
//  Copyright (c) 2015 lateralview. All rights reserved.
//

#import "CreditsVC.h"
#import "PlayerViewController.h"
#import "Item.h"

@interface CreditsVC ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong,nonatomic) PlayerViewController *videoPlayerVC;

@end

@implementation CreditsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setOrientation:UIInterfaceOrientationMaskPortrait];
    [self setAnimation];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"containerVideo"]){
    self.videoPlayerVC = [segue destinationViewController];
    self.videoPlayerVC.isCredits = NO;
    self.videoPlayerVC.isPortrait = YES;
    Item *item = [[Item alloc] init];
    
    if (!self.videoPlayerVC.isCredits) {//如果不用本地文件 就去用HLS直播流视频
        item.url = @"http://s3.amazonaws.com/truantvr360/videos/videos/000/000/003/original/parque_san_martin_logo.mp4?1429299657";
    }
    item.isVideo = YES;
    [self.videoPlayerVC setItem:item];
  }

  /*
    #warning  test url
    if ([segue.identifier isEqualToString:@"containerVideo"]){
        self.videoPlayerVC = [segue destinationViewController];
        self.videoPlayerVC.isCredits = NO;
        Item *item = [[Item alloc] init];
//        item.url = @"http://s3.amazonaws.com/truantvr360/videos/videos/000/000/003/original/parque_san_martin_logo.mp4?1429299657";
//        item.url = @"rtmp://pili-live-rtmp.snailvr.com/snailvr-test/mytest1446515073";
//      item.url = @"http://pili-live-hdl.snailvr.com/snailvr-test/mytest1446515073.flv";
//      item.url = @"http://pili-live-hls.snailvr.com/snailvr-test/mytest1446515073.m3u8";
      item.url = @"http://www.ossrs.net:8080/live/demo.1446704833022.1446704956484.1446705144107.m3u8";
        item.isVideo = YES;
        [self.videoPlayerVC setItem:item];
    }
   */
  
}

#pragma mark - NavTransition

-(void)setAnimation
{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = [UIColor colorWithRed:43/255 green:132/255 blue:210/255 alpha:1.f];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:43/255 green:132/255 blue:210/255 alpha:1.f];
    [UIView animateWithDuration:0.6f animations:^{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
    }];
}


@end
