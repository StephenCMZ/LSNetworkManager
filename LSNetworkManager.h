//
//  LSNetworkManager.h
//  LSNetworkManager
//
//  Created by StephenChen on 15/9/21.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSBaseRequest.h"

enum NetworkType {
    Unavail,
    Mobile,
    Wifi
};

@protocol LSNetworkStatus<NSObject>
- (void)lsNetworkStatus:(enum NetworkType) networkType;
@end

@interface LSNetworkManager : NSObject
@property AFHTTPRequestOperationManager *httpManager;

+ (BOOL)setUp;

+ (enum NetworkType)getStatus;
+ (void)setNetworkStatusHandler:(NSObject<LSNetworkStatus>*) statusHandler;

+ (void)send:(LSBaseRequest*)request;

+ (void)cancelRequest;

@end
