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
static NSString* const kHeaderNamePrefix = @"com.spotify.cache.";

@interface SPTPersistentCacheFileAttributesCoder ()

@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, strong) NSError* error;

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
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    int res = setxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (res == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorFileAttributeOperationFail];
    }
}

- (void)encodeUInt64:(uint64_t)intv forKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    int res = setxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (res == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorFileAttributeOperationFail];
    }
}

- (uint32_t)decodeUInt32ForKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    uint32_t intv = 0;
    ssize_t size = getxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (size == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorFileAttributeOperationFail];
    }
    return intv;
}

- (uint64_t)decodeUInt64ForKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    uint64_t intv = 0;
    ssize_t size = getxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (size == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorFileAttributeOperationFail];
    }
    return intv;
}

@end



@implementation SPTPersistentCacheFileAttributesArchiver

+ (BOOL)archivedCacheRecordHeader:(SPTPersistentCacheRecordHeader*)header toFileAtPath:(NSString*)filePath error:(NSError * __autoreleasing *)error
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFilePath:filePath];
    [header encodeWithCoder:coder];
    if (error) {
        *error = coder.error;
    }
    return coder.error == nil;
}

+ (SPTPersistentCacheRecordHeader*)unarchivedCacheRecordHeaderFromFileAtPath:(NSString*)filePath error:(NSError * __autoreleasing *)error
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFilePath:filePath];
    if (error) {
        *error = coder.error;
    }
    return [[SPTPersistentCacheRecordHeader alloc] initWithCoder:coder];
}

@end
