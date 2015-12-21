//
//  LSNetworkManager.m
//  LSNetworkManager
//
//  Created by StephenChen on 15/9/21.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import "LSNetworkManager.h"

static LSNetworkManager* mNetwork;
static NSObject<LSNetworkStatus> *mStatusHandler;

@implementation LSNetworkManager

+ (BOOL)setUp{
    
    if (!mNetwork) {
        mNetwork = [[LSNetworkManager alloc]init];
        mNetwork.httpManager = [AFHTTPRequestOperationManager manager];
        mNetwork.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil];
        mNetwork.httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        mNetwork.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self reach];
    }
    
    return YES;
}

+ (enum NetworkType)getStatus{
    if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
        return Wifi;
    }else if([AFNetworkReachabilityManager sharedManager].reachableViaWWAN){
        return Mobile;
    }else{
        return Unavail;
    };
}

+ (void)setNetworkStatusHandler:(NSObject<LSNetworkStatus>*) statusHandler{
    mStatusHandler = statusHandler;
}

+ (void)send:(LSBaseRequest*)request{
    if (!mNetwork) {
        return;
    }
    
    switch (request.method) {
        case GET:
            [self Get:request];
            break;
        case POST:
            [self Post:request];
            break;
        case POST_FILE:
            [self PostFile:request];
        default:
            break;
    }
}

+ (void)Get:(LSBaseRequest*)request{
    
    NSString* path = (request.path == nil)? @"": request.path;
    NSString* url = [NSString stringWithFormat:@"%@%@", request.baseUrl, path];
    
    [mNetwork.httpManager GET:url parameters:request.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (request.responser != nil) {
            NSError *error = nil;
            NSData *responseData = responseObject;
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            [request.responser success:responseDic withTag:request.tag];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (request.responser != nil) {
            [request.responser failure:error withTag:request.tag];
        }
    }];
}

+ (void)Post:(LSBaseRequest*)request{
    
    NSString* path = (request.path == nil)? @"": request.path;
    NSString* url = [NSString stringWithFormat:@"%@%@", request.baseUrl, path];
    
    [mNetwork.httpManager POST:url parameters:request.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (request.responser != nil) {
            NSError *error = nil;
            NSData *responseData = responseObject;
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            [request.responser success:responseDic withTag:request.tag];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (request.responser != nil) {
            [request.responser failure:error withTag:request.tag];
        }
    }];
}

+ (void)PostFile:(LSBaseRequest*)request{
    
    NSString *path = (request.path == nil)? @"": request.path;
    NSString *url = [NSString stringWithFormat:@"%@%@", request.baseUrl, path];
    NSString *fileName = @"fileName";
    
    NSMutableURLRequest *mRequest = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:request.params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:request.filePath] name:KEY_FILE fileName:fileName mimeType:request.fileType error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *respSerializer = [AFHTTPResponseSerializer serializer];
    respSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil];
    manager.responseSerializer = respSerializer;
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:mRequest progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if (request.responser != nil) {
                [request.responser failure:error withTag:request.tag];
            }
        } else {
            NSLog(@"%@ %@", response, responseObject);
            if (request.responser != nil) {
                NSError *error = nil;
                NSData *responseData = responseObject;
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                [request.responser success:responseDic withTag:request.tag];
            }
        }
    }];
    
    [uploadTask resume];
    
}

+ (void)cancelRequest{
    [[mNetwork.httpManager operationQueue] cancelAllOperations];
}

+ (void)reach{
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // wifi
     */
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (mStatusHandler == nil) {
            return;
        }
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
                [mStatusHandler lsNetworkStatus:Unavail];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [mStatusHandler lsNetworkStatus:Wifi];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [mStatusHandler lsNetworkStatus:Mobile];
                break;
            default:
                break;
        }
    }];
}

@end
