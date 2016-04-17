//
//  SPTPersistentCacheFileAttributesArchiver.m
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 07/05/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import "SPTPersistentCacheRecordHeaderArchiver.h"
#import "SPTPersistentCacheRecordHeader.h"
#import "NSError+SPTPersistentCacheDomainErrors.h"
#include <sys/xattr.h>

static int const SPTPersistentCacheHeaderInvalidResult = -1;
static NSString* const SPTPersistentCacheHeaderKeyPrefix = @"com.spotify.cache.";

@interface SPTPersistentCacheFileAttributesCoder ()

@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, assign) BOOL didFail;

@end

@implementation SPTPersistentCacheFileAttributesCoder

- (nullable instancetype)initWithFilePath:(NSString*)filePath
{
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
    }
    return self;
}

- (void)encodeUInt32:(uint32_t)intv forKey:(NSString *)key
{
    NSString* keypath = [SPTPersistentCacheHeaderKeyPrefix stringByAppendingString:key];
    int res = setxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    self.didFail = self.didFail || res == SPTPersistentCacheHeaderInvalidResult;
}

- (void)encodeUInt64:(uint64_t)intv forKey:(NSString *)key
{
    NSString* keypath = [SPTPersistentCacheHeaderKeyPrefix stringByAppendingString:key];
    int res = setxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    self.didFail = self.didFail || res == SPTPersistentCacheHeaderInvalidResult;
}

- (uint32_t)decodeUInt32ForKey:(NSString *)key
{
    NSString* keypath = [SPTPersistentCacheHeaderKeyPrefix stringByAppendingString:key];
    uint32_t intv = 0;
    ssize_t size = getxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    self.didFail = self.didFail || size == SPTPersistentCacheHeaderInvalidResult;
    return intv;
}

- (uint64_t)decodeUInt64ForKey:(NSString *)key
{
    NSString* keypath = [SPTPersistentCacheHeaderKeyPrefix stringByAppendingString:key];
    uint64_t intv = 0;
    ssize_t size = getxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    self.didFail = self.didFail || size == SPTPersistentCacheHeaderInvalidResult;
    return intv;
}

@end

@implementation SPTPersistentCacheFileAttributesArchiver

+ (BOOL)archivedCacheRecordHeader:(SPTPersistentCacheRecordHeader*)header toFileAtPath:(NSString*)filePath
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFilePath:filePath];
    [header encodeWithCoder:coder];
    return !coder.didFail;
}

+ (SPTPersistentCacheRecordHeader*)unarchivedCacheRecordHeaderFromFileAtPath:(NSString*)filePath
{
    SPTPersistentCacheFileAttributesCoder* decoder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFilePath:filePath];
    SPTPersistentCacheRecordHeader* header = [[SPTPersistentCacheRecordHeader alloc] initWithCoder:decoder];
    return decoder.didFail ? nil : header;
}

@end
