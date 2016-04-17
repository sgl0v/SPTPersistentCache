//
//  SPTPersistentCacheRecordHeader.h
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 20/04/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTPersistentCacheRecordHeaderArchiver.h"
#import "SPTPersistentCacheHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SPTPersistentCacheRecordHeaderRevision) {
    SPTPersistentCacheRecordHeaderRevisionLegacy    = 0,
    SPTPersistentCacheRecordHeaderRevision1         = 1
};

/**
 * The record header making up the front of the file index
 */
@interface SPTPersistentCacheRecordHeader : NSObject <SPTPersistentCacheFileAttributesCoding>

// Version 1:
@property (nonatomic, assign, readonly) uint32_t refCount;
@property (nonatomic, assign, readonly) uint32_t reserved1;
@property (nonatomic, assign, readonly) uint64_t ttl;
@property (nonatomic, assign, readonly) uint64_t updateTimeSec; // Time of last update i.e. creation or access. uses unix time scale.
@property (nonatomic, assign, readonly) uint64_t payloadSizeBytes;
@property (nonatomic, assign, readonly) uint64_t reserved2;
@property (nonatomic, assign, readonly) uint32_t reserved3;
@property (nonatomic, assign, readonly) uint32_t reserved4;
@property (nonatomic, assign, readonly) uint32_t flags; // See SPTPersistentRecordHeaderFlags
@property (nonatomic, assign, readonly) uint32_t crc;
@property (nonatomic, assign, readonly) uint32_t revision;

- (nullable instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)new NS_UNAVAILABLE;

- (nullable instancetype)initWithLegacyHeader:(SPTPersistentCacheRecordLegacyHeader)header;

@end

NS_ASSUME_NONNULL_END
