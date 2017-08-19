//
//  FCXRating.h
//  Universial
//
//  Created by 冯 传祥 on 15/8/23.
//  Copyright (c) 2015年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKStoreProductViewController.h>

@interface FCXRating : NSObject <SKStoreProductViewControllerDelegate>

/**
 *  调用评价
 *
 *  @param appID 当前应用的appID
 *  @param finish 好评逻辑完成后的回调
 */
+ (void)startRating:(NSString*)appID finish:(void(^)(BOOL success))finish;
+ (void)goAppStore:(NSString*)appID;//!<下载页
+ (void)goRating:(NSString *)appID;//!<评价页
+ (void)setup;


@end
