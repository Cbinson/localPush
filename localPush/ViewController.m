//
//  ViewController.m
//  localPush
//
//  Created by binsonchang on 2017/5/18.
//  Copyright © 2017年 tw.com.binson. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define UUID    @"B0702880-A295-A8AB-F734-031A98A512DE"
#define IDENTIFIER  @"senao.com.tw"

@interface ViewController ()<CLLocationManagerDelegate, CBPeripheralManagerDelegate>
{

}

@property(strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property(strong, nonatomic) CLLocationManager  *locationManager;
@property(strong, nonatomic) CBPeripheralManager *peripheralManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.requestAlwaysAuthorization;
    
    [self.locationManager startUpdatingLocation];

    [self setUpBeaconInfo];
    [self setUpPeriphera];

    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
}

-(void)setUpBeaconInfo {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:UUID];
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:IDENTIFIER];
}

-(void)setUpPeriphera {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

}

- (IBAction)clickPushBtn:(UIButton *)sender {

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Senao Online祝您神采奕奕";
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3]; // 3秒钟后

    //--------------------可选属性------------------------------
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) {
//        localNotification.alertTitle = @"推送通知提示标题：alertTitle"; // iOS8.2
//    }

    // 锁屏时在推送消息的最下方显示设置的提示字符串
    localNotification.alertAction = @"點擊查看";

    // 当点击推送通知消息时，首先显示启动图片，然后再打开App, 默认是直接打开App的
    localNotification.alertLaunchImage = @"LaunchImage.png";

    // 默认是没有任何声音的 UILocalNotificationDefaultSoundName：声音类似于震动的声音
    localNotification.soundName = UILocalNotificationDefaultSoundName;

    // 传递参数
    localNotification.userInfo = @{@"type": @"1"};

    //重复间隔：类似于定时器，每隔一段时间就发送通知
    //  localNotification.repeatInterval = kCFCalendarUnitSecond;

    localNotification.category = @"choose"; // 附加操作

    // 定时发送
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSInteger applicationIconBadgeNumber =  [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:applicationIconBadgeNumber];
}


//實作背景下也能接收beacon
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state != CBManagerStatePoweredOn) {
        NSLog(@"未開啟藍牙");
        return;
    }

    peripheral.delegate = self;

    [self setUpBeaconInfo];

    NSMutableDictionary *dict = [self.myBeaconRegion peripheralDataWithMeasuredPower:nil];
    [dict setObject:@"SenaoBeacon" forKey:CBAdvertisementDataLocalNameKey];

    [peripheral startAdvertising:dict];
}



#pragma mark - core location
//進入到myRegion會被呼叫
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count > 0) {
        CLBeacon *curBeacon = [beacons firstObject];    //第一個代表最接近device的beacon
        NSString *uuid = curBeacon.proximityUUID.UUIDString;
        int major = [curBeacon.major intValue];
        int minor = [curBeacon.minor intValue];
        NSInteger rssi = curBeacon.rssi;

        self.statusLabel.text = @"Beacon found!!";
        self.beaconInfoLabel.text = [NSString stringWithFormat:@"%@\n%d\n%d\n%ld",uuid,major,minor,(long)rssi];

        //發本地推撥
        [self clickPushBtn:self.pushBtn];

    }else{
        self.statusLabel.text = @"exit Beacon";
        self.beaconInfoLabel.text = @"";
    }
}


//進入
- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

//離開
-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    self.statusLabel.text = @"No";
    self.beaconInfoLabel.text = @"";
}

//- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
//    if(state == CLRegionStateInside){
//        if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
//            [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
//        }
//    }
//}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
//    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
