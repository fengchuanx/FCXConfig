//
//  FCXRating.h
//  Universial
//
//  Created by 冯 传祥 on 15/8/23.
//  Copyright (c) 2015年 冯 传祥. All rights reserved.
//

#import "FCXRating.h"
#import "FCXGuide.h"
#import "UMFeedback.h"
#import "FCXOnlineConfig.h"
#import "UMMobClick/MobClick.h"

#define HASRATING @"HasRating"

@implementation FCXRating
{
    NSString *_county;
}

+ (void)setup {
    [[FCXRating sharedRating] requestIP:NULL];
}

+ (void)startRating:(NSString *)appID finish:(void (^)(BOOL))finish {
    return [[FCXRating sharedRating] fcx_startRating:appID finish:finish];
}

+ (FCXRating *)sharedRating {
    static FCXRating *rating;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rating = [[FCXRating alloc] init];
    });
    return rating;
}

- (void)fcx_startRating:(NSString *)appID finish:(void (^)(BOOL))finish {
    BOOL showRating = [[FCXOnlineConfig fcxGetConfigParams:@"showRating" defaultValue:@"0"] boolValue];
    if (!showRating) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    [self checkAppVersion];
    
    if (self.hasRating) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    BOOL judgeIP = [FCXOnlineConfig fcxGetConfigParams:@"judgeIP" defaultValue:@"1"].boolValue;
    if (judgeIP) {//判断IP
        NSDictionary *timeDict = [FCXOnlineConfig fcxGetJSONConfigParams:@"ratingTime"];
        NSInteger min = 10, max = 21;
        if (timeDict) {
            min = [timeDict[@"min"] integerValue];
            max = [timeDict[@"max"] integerValue];
        }
        NSInteger hour = [self getCurrentDate:@"HH" forKey:@"RatingDateFormatter_Hour"].integerValue;
        if (hour < min || hour > max) {//时间段不满足
            if (finish) {
                finish(NO);
            }
            return;
        }
        
        if (_county) {
            if ([_county isEqualToString:@"中国"]) {
                [self showRating:appID finish:finish];
            } else {
                if (finish) {
                    finish(NO);
                }
            }
        } else {
            [self requestIP:^(NSString *county) {
                if (county && [county isEqualToString:@"中国"]) {
                    [self showRating:appID finish:finish];
                } else {
                    if (finish) {
                        finish(NO);
                    }
                }
            }];
        }
    } else {//不判断IP
        [self showRating:appID finish:finish];
    }
}

- (void)showRating:(NSString *)appID finish:(void (^)(BOOL))finish {
    NSDictionary *paramsDict = [FCXOnlineConfig fcxGetJSONConfigParams:@"ratingContent"];
    if (![paramsDict isKindOfClass:[NSDictionary class]]) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    //    NSLog(@"==%@", paramsDict);
    NSString *title = [paramsDict objectForKey:@"标题"];
    NSString *content = [paramsDict objectForKey:@"内容"];
    NSString *btn1 = [paramsDict objectForKey:@"按钮1"];
    NSString *btn2 = [paramsDict objectForKey:@"按钮2"];
    //    NSString *btn3 = [paramsDict objectForKey:@"按钮3"];
    NSInteger alertTimes = [[paramsDict objectForKey:@"总提醒次数"] integerValue];
    
    if (!title || !content || !btn1 || !btn2) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentDateString = [self getCurrentDate:@"YYYY-MM-dd" forKey:@"RatingDateFormatter"];
    NSString *alertDateString = [userDefaults objectForKey:@"alertDate"];
    if (alertDateString && [alertDateString isEqualToString:currentDateString]) {//当天弹出过
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    if ([userDefaults integerForKey:@"alertTimes"] >= alertTimes) {//超过弹出次数
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    MAlertViw *alertView = [[MAlertViw alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:nil otherButtonTitles:btn1, btn2, nil];
    alertView.dismiss = YES;
    [alertView show];
    
    alertView.handleAction = ^(MAlertViw *alertView, NSInteger buttonIndex){
        
        if (buttonIndex == 0) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                [vc presentViewController:[UMFeedback feedbackModalViewController] animated:YES completion:^{
                    
                }];
            });
            
        }else if(buttonIndex == 1) {
            
            [FCXRating goRating:appID];
            [FCXRating saveRating];
        }else {
            //            [FCXRating saveRating];
        }
    };
    
    [self saveAlert];
    if (finish) {
        finish(YES);
    }
}

//保存提醒的日期和次数
- (void)saveAlert {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentDateString = [self getCurrentDate:@"YYYY-MM-dd" forKey:@"RatingDateFormatter"];
    NSInteger alertTimes = [userDefaults integerForKey:@"alertTimes"];
    alertTimes++;
    
    [userDefaults setObject:currentDateString forKey:@"alertDate"];
    [userDefaults setObject:[NSNumber numberWithInteger:alertTimes] forKey:@"alertTimes"];
    [userDefaults synchronize];
}

//获取当前时间的字符串
- (NSString *)getCurrentDateString11 {
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey: @"RatingDateFormatter"] ;
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat: @"YYYY-MM-dd"] ;
        [threadDictionary setObject: dateFormatter forKey: @"RatingDateFormatter"] ;
    }
    return [dateFormatter stringFromDate:[NSDate date]];
}

//获取当前时间的字符串
- (NSString *)getCurrentDate:(NSString *)dateFormatter forKey:(NSString *)key {
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *_dateFormatter = [threadDictionary objectForKey:key] ;
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc] init] ;
        [_dateFormatter setDateFormat:dateFormatter];
        [threadDictionary setObject:_dateFormatter forKey:key] ;
    }
    return [_dateFormatter stringFromDate:[NSDate date]];
}


//检查版本，如果版本不一致，清除之前版本的缓存
- (void)checkAppVersion {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ratingVersion = [userDefaults objectForKey:@"RatingAppVersion"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (!ratingVersion) {//之前没有存过版本，第一次存
        
        ratingVersion = appVersion;
        [userDefaults setObject:ratingVersion forKey:@"RatingAppVersion"];
    }else if(![ratingVersion isEqualToString:appVersion]) {//版本升级，清空之前缓存
        
        ratingVersion = appVersion;
        [userDefaults setObject:ratingVersion forKey:@"RatingAppVersion"];
        
        //清楚之前版本的缓存
        [userDefaults removeObjectForKey:HASRATING];
        [userDefaults removeObjectForKey:@"alertTimes"];
    }
    [userDefaults synchronize];
}

- (BOOL)hasRating {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:HASRATING];
}

+ (void)saveRating {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HASRATING];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)goAppStore:(NSString*)appID {
    if (![appID isKindOfClass:[NSString class]]) {
        return;
    }
    // 打开应用内购买
    SKStoreProductViewController *vc = [[SKStoreProductViewController alloc] init];
    
    vc.delegate = [FCXRating sharedRating];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appID forKey:SKStoreProductParameterITunesItemIdentifier];
    [vc loadProductWithParameters:dict completionBlock:nil];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

+ (void)goRating:(NSString *)appID {
    if (![appID isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *strUrl =[NSString stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appID];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strUrl]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
    }else{
        strUrl =[NSString stringWithFormat: @"https://itunes.apple.com/app/id%@", appID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
    }
}

- (void)requestIP:(void (^)(NSString *county))finish {
    NSString *urlString = @"http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json";

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval: 2];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//            NSLog(@"json ==%@ ==%@", dict, dict[@"country"]);
            if ([dict isKindOfClass:[NSDictionary class]]) {
                _county = dict[@"country"];
                if (finish) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        finish(_county);
                    });
                }
            } else if (finish) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    finish(nil);
                });
            }
        } else if (finish) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finish(nil);
            });
        }
        /*
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSLog(@"respod %@  header  %@", response,[(NSHTTPURLResponse *)response allHeaderFields]);
            
            NSString *dateString = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Date"];
            dateString = [dateString substringWithRange:NSMakeRange(5, 20)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
            
            dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
            
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+0800"]];
            dateString = [dateFormatter stringFromDate:date];
            NSInteger house = [[dateString substringWithRange:NSMakeRange(12, 2)] integerValue];
            if (house >= 11 && house <= 20) {//符合时间
                
            }
        }
         */
    }];
    [task resume];
}

@end
