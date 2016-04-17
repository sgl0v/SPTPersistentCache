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
@property (nonatomic, assign) NSInteger fileDescriptor;
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

- (nullable instancetype)initWithFile:(NSInteger)fileDescriptor
{
    self = [super init];
    if (self) {
        _fileDescriptor = fileDescriptor;
    }
    return self;
}

- (void)encodeUInt32:(uint32_t)intv forKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    int res = setxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (res == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        //        const int errorNumber = errno;
        //        NSString *errorDescription = @(strerror(errorNumber));
        //        self.error = [NSError errorWithDomain:SPTPersistentCacheErrorDomain
        //                                         code:errorNumber
        //                                     userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorInternalInconsistency];
    }
}

- (void)encodeUInt64:(uint64_t)intv forKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    int res = setxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (res == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        //        const int errorNumber = errno;
        //        NSString *errorDescription = @(strerror(errorNumber));
        //        self.error = [NSError errorWithDomain:SPTPersistentCacheErrorDomain
        //                                         code:errorNumber
        //                                     userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorInternalInconsistency];
    }
}

- (uint32_t)decodeUInt32ForKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    uint32_t intv = 0;
    ssize_t size = getxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (size == SPTPersistentCacheHeaderInvalidResult && !self.error) {
        //        const int errorNumber = errno;
        //        NSString *errorDescription = @(strerror(errorNumber));
        //        self.error = [NSError errorWithDomain:SPTPersistentCacheErrorDomain
        //                                         code:errorNumber
        //                                     userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorInternalInconsistency];
    }
    return intv;
}

- (uint64_t)decodeUInt64ForKey:(NSString *)key
{
    NSString* keypath = [kHeaderNamePrefix stringByAppendingString:key];
    uint64_t intv = 0;
    ssize_t size = getxattr([self.filePath UTF8String], [keypath UTF8String], &intv, sizeof(intv), 0, 0);
    if (size == SPTPersistentCacheHeaderInvalidResult && !self.error) {
//        const int errorNumber = errno;
//        NSString *errorDescription = @(strerror(errorNumber));
//        self.error = [NSError errorWithDomain:SPTPersistentCacheErrorDomain
//                                         code:errorNumber
//                                     userInfo:@{ NSLocalizedDescriptionKey: errorDescription }];
        self.error = [NSError spt_persistentDataCacheErrorWithCode:SPTPersistentCacheLoadingErrorInternalInconsistency];
    }
    return intv;
}

@end



@implementation SPTPersistentCacheFileAttributesArchiver

+ (void)archivedCacheRecordHeader:(NSObject <SPTPersistentCacheFileAttributesCoding>*)header toFile:(NSInteger)fileDescriptor
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFile:fileDescriptor];
    [header encodeWithCoder:coder];
}

+ (void)archivedCacheRecordHeader:(NSObject <SPTPersistentCacheFileAttributesCoding>*)header toFileWithPath:(NSString*)filepath
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFilePath:filepath];
    [header encodeWithCoder:coder];
}

+ (SPTPersistentCacheRecordHeader*)unarchivedCacheRecordHeaderFromFile:(NSInteger)fileDescriptor
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFile:fileDescriptor];
    return [[SPTPersistentCacheRecordHeader alloc] initWithCoder:coder];
}

+ (SPTPersistentCacheRecordHeader*)unarchivedCacheRecordHeaderFromFileWithPath:(NSString*)filepath
{
    SPTPersistentCacheFileAttributesCoder* coder = [[SPTPersistentCacheFileAttributesCoder alloc] initWithFilePath:filepath];
    return [[SPTPersistentCacheRecordHeader alloc] initWithCoder:coder];
}

@end
