//
//  LSBaseRequest.h
//  LSNetworkManager
//
//  Created by StephenChen on 15/9/21.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSNetworkManager.h"

enum Method {
    GET,
    POST,
    POST_FILE,
};

@protocol LSNetworkResponser <NSObject>

-(void) success:(id) responseObject withTag:(int)tag;
-(void) failure:(NSError*) error withTag:(int)tag;

@end

@interface LSBaseRequest : NSObject

@property (nonatomic,strong) id<LSNetworkResponser> responser;
@property enum Method method;
@property(nonatomic) int tag;

@property(nonatomic, copy) NSString *baseUrl;
@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSMutableDictionary *params;

@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,copy) NSString *fileType;


-(instancetype)init:(NSString*)path method:(enum Method) method;
-(void) go;

@end
