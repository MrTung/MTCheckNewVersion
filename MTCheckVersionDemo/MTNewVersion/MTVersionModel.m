//
//  MTVersionModel.m
//  QinQingBao
//
//  Created by 董徐维 on 2016/12/7.
//  Copyright © 2016年 董徐维. All rights reserved.
//

#import "MTVersionModel.h"

@implementation MTVersionModel
- (instancetype)initWithResult:(NSDictionary *)result{
    
    self = [super init];
    if (self) {
        self.version = result[@"version"];
        self.releaseNotes = result[@"releaseNotes"];
        self.trackId = result[@"trackId"];
        self.bundleId = result[@"bundleId"];
        self.trackViewUrl = result[@"trackViewUrl"];
        self.appDescription = result[@"appDescription"];
        self.sellerName = result[@"sellerName"];
        self.fileSizeBytes = result[@"fileSizeBytes"];
        self.screenshotUrls = result[@"screenshotUrls"];
        self.currentVersionReleaseDate = result[@"currentVersionReleaseDate"];
    }
    return self;
}
@end
