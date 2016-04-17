//
//  SPTPersistentCacheRecordHeader.m
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 20/04/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import "SPTPersistentCacheRecordHeader.h"
#import "crc32iso3309.h"

const SPTPersistentCacheRecordHeaderRevision SPTPersistentCacheRecordHeaderCurrentRevision = SPTPersistentCacheRecordHeaderRevision1;

@implementation SPTPersistentCacheRecordHeader

- (nullable instancetype)initWithLegacyHeader:(SPTPersistentCacheRecordLegacyHeader*)header
{
    self = [super init];
    if (self) {
        _refCount = header->refCount;
        _reserved1 = header->reserved1;
        _ttl = header->ttl;
        _updateTimeSec = header->updateTimeSec;
        _payloadSizeBytes = header->payloadSizeBytes;
        _reserved2 = header->reserved2;
        _reserved3 = header->reserved3;
        _reserved4 = header->reserved4;
        _flags = header->flags;
        _revision = SPTPersistentCacheRecordHeaderCurrentRevision;
        _crc = [self calculateCRC32];
    }
    return self;
}

- (instancetype)initWithTTL:(uint64_t)ttl payloadSize:(uint64_t)payloadSize updateTime:(uint64_t)updateTime isLocked:(BOOL)isLocked
{
    self = [super init];
    if (self) {
        _refCount = (isLocked ? 1 : 0);
        _ttl = ttl;
        _payloadSizeBytes = payloadSize;
        _updateTimeSec = updateTime;
        _revision = SPTPersistentCacheRecordHeaderCurrentRevision;
        _crc = [self calculateCRC32];
    }
    return self;
}

#pragma mark - SPTPersistentCacheFileAttributesCoding

- (void)encodeWithCoder:(SPTPersistentCacheFileAttributesCoder *)aCoder
{
    [aCoder encodeUInt32:self.refCount forKey:NSStringFromSelector(@selector(refCount))];
    [aCoder encodeUInt32:self.reserved1 forKey:NSStringFromSelector(@selector(reserved1))];
    [aCoder encodeUInt64:self.ttl forKey:NSStringFromSelector(@selector(ttl))];
    [aCoder encodeUInt64:self.updateTimeSec forKey:NSStringFromSelector(@selector(updateTimeSec))];
    [aCoder encodeUInt64:self.payloadSizeBytes forKey:NSStringFromSelector(@selector(payloadSizeBytes))];
    [aCoder encodeUInt64:self.reserved2 forKey:NSStringFromSelector(@selector(reserved2))];
    [aCoder encodeUInt32:self.reserved3 forKey:NSStringFromSelector(@selector(reserved3))];
    [aCoder encodeUInt32:self.reserved4 forKey:NSStringFromSelector(@selector(reserved4))];
    [aCoder encodeUInt32:self.flags forKey:NSStringFromSelector(@selector(flags))];
    [aCoder encodeUInt32:self.crc forKey:NSStringFromSelector(@selector(crc))];
    [aCoder encodeUInt32:self.revision forKey:NSStringFromSelector(@selector(revision))];
}

- (nullable instancetype)initWithCoder:(SPTPersistentCacheFileAttributesCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _refCount = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(refCount))];
        _reserved1 = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(reserved1))];
        _ttl = [aDecoder decodeUInt64ForKey:NSStringFromSelector(@selector(ttl))];
        _updateTimeSec = [aDecoder decodeUInt64ForKey:NSStringFromSelector(@selector(updateTimeSec))];
        _payloadSizeBytes = [aDecoder decodeUInt64ForKey:NSStringFromSelector(@selector(payloadSizeBytes))];
        _reserved2 = [aDecoder decodeUInt64ForKey:NSStringFromSelector(@selector(reserved2))];
        _reserved3 = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(reserved3))];
        _reserved4 = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(reserved4))];
        _flags = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(flags))];
        _crc = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(crc))];
        _revision = [aDecoder decodeUInt32ForKey:NSStringFromSelector(@selector(revision))];
    }
    return self;
}

#pragma mark - Private

- (uint32_t) calculateCRC32 {
    [NSKeyedArchiver archivedDataWithRootObject:@(self.ttl)];
    NSMutableData* rawHeader = [NSMutableData data];
    [rawHeader appendBytes:&self.ttl length:sizeof(self.ttl)];
    return spt_crc32((const uint8_t *)[rawHeader bytes], rawHeader.length);
}

@end
