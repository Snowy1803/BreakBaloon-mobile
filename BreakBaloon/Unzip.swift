//
//  Unzip.swift
//  BreakBaloon
//
//  Created by Emil on 01/07/2016.
//  Copyright © 2016 Snowy_1803. All rights reserved.
//

import Foundation
import Compression

class Unzip {
    
    
    @available(iOS 9.0, *)
    func unzip(compressedData:NSData) -> NSData? {
        let streamPtr = UnsafeMutablePointer<compression_stream>.alloc(1)
        var stream = streamPtr.memory
        var status: compression_status
        
        status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
        stream.src_ptr = UnsafePointer<UInt8>(compressedData.bytes)
        stream.src_size = compressedData.length
        
        let dstBufferSize: size_t = 4096
        let dstBufferPtr = UnsafeMutablePointer<UInt8>.alloc(dstBufferSize)
        stream.dst_ptr = dstBufferPtr
        stream.dst_size = dstBufferSize
        
        let decompressedData = NSMutableData()
        
        repeat {
            status = compression_stream_process(&stream, 0)
            switch status {
            case COMPRESSION_STATUS_OK:
                if stream.dst_size == 0 {
                    decompressedData.appendBytes(dstBufferPtr, length: dstBufferSize)
                    stream.dst_ptr = dstBufferPtr
                    stream.dst_size = dstBufferSize
                }
            case COMPRESSION_STATUS_END:
                if stream.dst_ptr > dstBufferPtr {
                    decompressedData.appendBytes(dstBufferPtr, length: stream.dst_ptr - dstBufferPtr)
                }
            default:
                break
            }
        }
        while status == COMPRESSION_STATUS_OK
        
        compression_stream_destroy(&stream)
        
        if status == COMPRESSION_STATUS_END {
            return decompressedData
        } else {
            print("Unzipping failed")
            return nil
        }
    }
}