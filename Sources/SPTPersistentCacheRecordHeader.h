//
//  SPTPersistentCacheRecordHeader.h
//  SPTPersistentCache
//
//  Created by Maksym Shcheglov on 20/04/16.
//  Copyright © 2016 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The record header making up the front of the file index
 */
@interface SPTPersistentCacheRecordHeader : NSObject

// Version 1:
@property (nonatomic, assign, readonly) uint32_t headerSize;
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

// Version 2: Add fields here if required

@end

NS_ASSUME_NONNULL_END
