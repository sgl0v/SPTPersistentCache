/*
 * Copyright (c) 2016 Spotify AB.
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
#import <XCTest/XCTest.h>

#import "SPTPersistentCacheHeader.h"
#import <SPTPersistentCache/SPTPersistentCache.h>
#import "SPTPersistentCacheTypeUtilities.h"

static NSString* const SPTCacheRecordFileName = @"cache.record";


@interface SPTPersistentCacheHeaderTests : XCTestCase

@end

@implementation SPTPersistentCacheHeaderTests

- (void)testGetHeaderFromDataWithSmallSizeData
{
    size_t smallerSize = SPTPersistentCacheRecordHeaderSize - 1;
    void *smallData = malloc(smallerSize);
    
    XCTAssertEqual(SPTPersistentCacheGetHeaderFromData(smallData, smallerSize), NULL);
    
    free(smallData);
}

- (void)testGetHeaderFromDataWithRightSize
{
    size_t rightHeaderSize = SPTPersistentCacheRecordHeaderSize;
    void *data = malloc(rightHeaderSize);
    
    XCTAssertEqual(SPTPersistentCacheGetHeaderFromData(data, rightHeaderSize), data);
    
    free(data);
}

- (void)testValidateMisalignedHeader
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wcast-align"
    int headerValidationResult = SPTPersistentCacheValidateHeader((SPTPersistentCacheRecordLegacyHeader *)3);
    #pragma mark diagnostic pop
    XCTAssertEqual(headerValidationResult, SPTPersistentCacheLoadingErrorHeaderAlignmentMismatch);
}

- (void)testValidateNULLHeader
{
    int headerValidationResult = SPTPersistentCacheValidateHeader(NULL);
    
    XCTAssertEqual(headerValidationResult, SPTPersistentCacheLoadingErrorInternalInconsistency);
}

- (void)testCalculateNULLHeaderCRC
{
    uint32_t headerCRC = SPTPersistentCacheCalculateHeaderCRC(NULL);
    
    XCTAssertEqual(headerCRC, (uint32_t)0);
}

- (void)testSPTPersistentCacheRecordHeaderMake
{
    uint64_t ttl = 64;
    uint64_t payloadSize = 400;
    uint64_t updateTime = spt_uint64rint([[NSDate date] timeIntervalSince1970]);
    BOOL isLocked = YES;
    
    
    SPTPersistentCacheRecordLegacyHeader header = SPTPersistentCacheRecordHeaderMake(ttl,
                                                                               payloadSize,
                                                                               updateTime,
                                                                               isLocked);
    
    XCTAssertEqual(header.reserved1, (uint64_t)0);
    XCTAssertEqual(header.reserved2, (uint64_t)0);
    XCTAssertEqual(header.reserved3, (uint64_t)0);
    XCTAssertEqual(header.reserved4, (uint64_t)0);
    XCTAssertEqual(header.flags, (uint32_t)0);
    XCTAssertEqual(header.magic, SPTPersistentCacheMagicValue);
    XCTAssertEqual(header.headerSize, (uint32_t)SPTPersistentCacheRecordHeaderSize);
    XCTAssertEqual(!!header.refCount, isLocked);
    XCTAssertEqual(header.ttl, ttl);
    XCTAssertEqual(header.payloadSizeBytes, payloadSize);
    XCTAssertEqual(header.updateTimeSec, updateTime);
    XCTAssertEqual(header.crc, SPTPersistentCacheCalculateHeaderCRC(&header));
}

- (void)testSPTPersistentCacheGetHeaderFromFileWithPath
{
    // GIVEN
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:SPTCacheRecordFileName];
    [self removeFileAtPath:filePath];
    SPTPersistentCacheRecordLegacyHeader header = [self dummyHeader];
    XCTAssertNil([self createRecordAtPath:filePath withHeader:&header]);

    // WHEN
    SPTPersistentCacheRecordLegacyHeader loadedHeader;
    NSError* error = SPTPersistentCacheGetHeaderFromFileWithPath(filePath, &loadedHeader);

    // THEN
    XCTAssertNil(error);
    XCTAssertEqual(header.reserved1, loadedHeader.reserved1);
    XCTAssertEqual(header.reserved2, loadedHeader.reserved2);
    XCTAssertEqual(header.reserved3, loadedHeader.reserved3);
    XCTAssertEqual(header.reserved4, loadedHeader.reserved4);
    XCTAssertEqual(header.flags, loadedHeader.flags);
    XCTAssertEqual(header.magic, loadedHeader.magic);
    XCTAssertEqual(header.headerSize, loadedHeader.headerSize);
    XCTAssertEqual(header.refCount, loadedHeader.refCount);
    XCTAssertEqual(header.ttl, loadedHeader.ttl);
    XCTAssertEqual(header.payloadSizeBytes, loadedHeader.payloadSizeBytes);
    XCTAssertEqual(header.updateTimeSec, loadedHeader.updateTimeSec);
    XCTAssertEqual(header.crc, loadedHeader.crc);

    [self removeFileAtPath:filePath];
}

- (void)testSPTPersistentCacheGetHeaderFromFileWithPathFailsWithError
{
    // GIVEN
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:SPTCacheRecordFileName];

    // WHEN
    SPTPersistentCacheRecordLegacyHeader loadedHeader;
    NSError* error = SPTPersistentCacheGetHeaderFromFileWithPath(filePath, &loadedHeader);

    // THEN
    XCTAssertNotNil(error);
}

- (void)testSPTPersistentCacheGetHeaderFromFileWithPathLegacy
{
    // GIVEN
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:SPTCacheRecordFileName];
    [self removeFileAtPath:filePath];
    SPTPersistentCacheRecordLegacyHeader header = [self dummyHeader];
    NSData* payload = [[NSMutableData dataWithLength:header.payloadSizeBytes] copy];
    NSMutableData* rawData = [NSMutableData dataWithBytes:&header length:SPTPersistentCacheRecordHeaderSize];
    [rawData appendData:payload];
    XCTAssertTrue([[NSFileManager defaultManager] createFileAtPath:filePath contents:rawData attributes:nil]);

    // WHEN
    SPTPersistentCacheRecordLegacyHeader loadedHeader;
    NSError* error = SPTPersistentCacheGetHeaderFromFileWithPath(filePath, &loadedHeader);

    // THEN
    XCTAssertNil(error);
    XCTAssertEqual(header.reserved1, loadedHeader.reserved1);
    XCTAssertEqual(header.reserved2, loadedHeader.reserved2);
    XCTAssertEqual(header.reserved3, loadedHeader.reserved3);
    XCTAssertEqual(header.reserved4, loadedHeader.reserved4);
    XCTAssertEqual(header.flags, loadedHeader.flags);
    XCTAssertEqual(header.magic, loadedHeader.magic);
    XCTAssertEqual(header.headerSize, loadedHeader.headerSize);
    XCTAssertEqual(header.refCount, loadedHeader.refCount);
    XCTAssertEqual(header.ttl, loadedHeader.ttl);
    XCTAssertEqual(header.payloadSizeBytes, loadedHeader.payloadSizeBytes);
    XCTAssertEqual(header.updateTimeSec, loadedHeader.updateTimeSec);
    XCTAssertEqual(header.crc, loadedHeader.crc);

    [self removeFileAtPath:filePath];
}

- (void)testSPTPersistentCacheSetHeaderForFileWithPath
{
    // GIVEN
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:SPTCacheRecordFileName];
    [self removeFileAtPath:filePath];
    SPTPersistentCacheRecordLegacyHeader header = [self dummyHeader];

    // WHEN
    NSError* error = [self createRecordAtPath:filePath withHeader:&header];

    // THEN
    XCTAssertNil(error);

    [self removeFileAtPath:filePath];
}

- (void)testSPTPersistentCacheSetHeaderForFileWithPathFailsWithError
{
    // GIVEN
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:SPTCacheRecordFileName];

    // WHEN
    SPTPersistentCacheRecordLegacyHeader loadedHeader;
    NSError* error = SPTPersistentCacheSetHeaderForFileWithPath(filePath, &loadedHeader);

    // THEN
    XCTAssertNotNil(error);
}

#pragma mark - Private

- (NSError*)createRecordAtPath:(NSString*)filePath withHeader:(SPTPersistentCacheRecordLegacyHeader*)header
{
    NSMutableData* data = [NSMutableData dataWithLength:header->payloadSizeBytes];

    XCTAssertTrue([[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil]);
    return SPTPersistentCacheSetHeaderForFileWithPath(filePath, header);
}

- (void)removeFileAtPath:(NSString*)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        XCTAssertNil(error);
    }
}

- (SPTPersistentCacheRecordLegacyHeader)dummyHeader {
    uint64_t ttl = 64;
    uint64_t payloadSize = 400;
    uint64_t updateTime = spt_uint64rint([[NSDate date] timeIntervalSince1970]);
    BOOL isLocked = YES;

    return SPTPersistentCacheRecordHeaderMake(ttl, payloadSize, updateTime, isLocked);
}

@end
