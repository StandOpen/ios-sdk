//
//  QiniuUtils.m
//  QiniuSDK
//
//  Created by Qiniu Developers 2013
//

#import <UIKit/UIKit.h>

#import "QiniuConfig.h"
#import "QiniuUtils.h"

#define kQiniuErrorKey     @"error"
#define kQiniuErrorDomain  @"QiniuErrorDomain"

NSError *qiniuError(int errorCode, NSString *errorDescription) {
    return [NSError errorWithDomain:kQiniuErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:kQiniuErrorKey]];
}

NSError *qiniuErrorWithOperation(AFHTTPRequestOperation *operation, NSError *error) {

    if (operation == nil || operation.responseObject == nil) {
        return error;
    }

    NSMutableDictionary *userInfo = nil;
    NSInteger errorCode = -1;

    if ([operation.responseObject isKindOfClass:NSDictionary.class]) {
        userInfo = [NSMutableDictionary dictionaryWithDictionary:operation.responseObject];
    }
    errorCode = [operation.response statusCode];

    if (!userInfo) {
        userInfo = [NSMutableDictionary init];
    }

    NSString *reqid = [[operation.response allHeaderFields] objectForKey:@"X-Reqid"];
    [userInfo setObject:reqid forKey:@"reqid"];

    return [NSError errorWithDomain:kQiniuErrorDomain code:errorCode userInfo:userInfo];
}

static NSString* clientId(){
    long long now_timestamp = [[NSDate date] timeIntervalSince1970]*1000;
    int r = arc4random()%1000;
    return [NSString stringWithFormat:@"%lld%u", now_timestamp, r];
}

static NSString* _clientId = nil;

NSString *qiniuUserAgent() {
    if (_clientId == nil){
        _clientId = clientId();
    }
    return  [NSString stringWithFormat:@"Qiniu-iOS/%@ (%@; iOS %@; %@)", kQiniuVersion, [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], _clientId];
}

BOOL isRetryHost(AFHTTPRequestOperation *operation) {

    NSInteger errorCode = [operation.response statusCode];

    if (errorCode / 100 == 4 || errorCode / 100 == 6 || errorCode / 100 == 7) {
        return false;
    }
    if (errorCode == 579 || errorCode == 599) {
        return false;
    }
    return true;
}
