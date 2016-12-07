//
//  MTVersionHelper.m
//  QinQingBao
//
//  Created by 董徐维 on 2016/12/7.
//  Copyright © 2016年 董徐维. All rights reserved.
//

#import "MTVersionHelper.h"

#import <StoreKit/StoreKit.h>

@interface MTVersionHelper()<UIAlertViewDelegate,SKStoreProductViewControllerDelegate>

@property(nonatomic,strong)MTVersionModel *appInfo;

@end

@implementation MTVersionHelper

+(void)checkNewVersion
{
    [[MTVersionHelper shardManger] checkNewVersion];
}

+(void)checkNewVersionAndCustomAlert:(NewVersionBlock)newVersion
{
    [[MTVersionHelper shardManger] checkNewVersionAndCustomAlert:newVersion];
}

#pragma mark - 单例

+(MTVersionHelper *)shardManger
{
    static MTVersionHelper *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        
        instance = [[MTVersionHelper alloc] init];
        
    });
    return instance;
}

#pragma mark - checkVersion

-(void)checkNewVersion
{
    
    [self versionRequest:^(MTVersionModel *appInfo) {
        
        NSString *updateMsg = [NSString stringWithFormat:@"%@",appInfo.releaseNotes];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:updateMsg delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
        [alertView show];
#endif
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:updateMsg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.appInfo.trackViewUrl]];
            
        }]];
        
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
#endif
    }];
}

-(void)checkNewVersionAndCustomAlert:(NewVersionBlock)newVersion
{
    [self versionRequest:^(MTVersionModel *appInfo) {
        
        if(newVersion)
            newVersion(appInfo);
        
    }];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appInfo.trackViewUrl]];
    }
}
#endif

/**
 打开新版本下载链接
 @param appId appId
 */
- (void)openInStoreProductViewControllerForAppId:(NSString *)appId
{
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    storeProductVC.delegate = self;
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
    
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 对比版本号是否一致

-(BOOL)isNewVersion:(NSString *)newVersion
{
    return [self newVersion:newVersion moreThanCurrentVersion:[self currentVersion]];
}

-(NSString * )currentVersion
{
    NSString *key = @"CFBundleShortVersionString";
    NSString * currentVersion = [NSBundle mainBundle].infoDictionary[key];
    return currentVersion;
}

-(BOOL)newVersion:(NSString *)newVersion moreThanCurrentVersion:(NSString *)currentVersion
{
    if([currentVersion compare:newVersion options:NSNumericSearch]==NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

#pragma mark 获取线上版本信息
/**
 获取store的app信息

 @param newVersion <#newVersion description#>
 */
-(void)versionRequest:(NewVersionBlock)newVersion
{
    [self xh_versionRequestSuccess:^(NSDictionary *responseDict) {
        
        NSInteger resultCount = [responseDict[@"resultCount"] integerValue];
        if(resultCount==1)
        {
            NSArray *resultArray = responseDict[@"results"];
            NSDictionary *result = resultArray.firstObject;
            MTVersionModel *appInfo = [[MTVersionModel alloc] initWithResult:result];
            NSString *version = appInfo.version;
            self.appInfo = appInfo;
            if([self isNewVersion:version])//新版本
            {
                if(newVersion)
                    newVersion(self.appInfo);
            }
        }
        else
        {
            NSLog(@"app store上没有找到该app");
        }
        
    } failure:^(NSError *error) {
        
    }];
    
}

/**
 获取appstore上app的信息
 @param success success description
 @param failure failure description
 */
-(void)xh_versionRequestSuccess:(void (^)(NSDictionary * responseDict))success failure:(void (^)(NSError *error))failure{
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = infoDict[@"CFBundleIdentifier"];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",bundleId]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(!error)
                {
                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    if(success) success(responseDict);
                }
                else
                {
                    if(failure) failure(error);
                }
                
            });
            
        }];
        [dataTask resume];
    });
}
@end
