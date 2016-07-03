/*
 * DeflateSwift (deflate.swift)
 *
 * Copyright (C) 2015 ONcast, LLC. All Rights Reserved.
 * Created by Josh Baker (joshbaker77@gmail.com)
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 */

import Foundation

public class ZStream {
    private struct z_stream {
        private var next_in : UnsafePointer<UInt8> = nil
        private var avail_in : CUnsignedInt = 0
        private var total_in : CUnsignedLong = 0
        
        private var next_out : UnsafePointer<UInt8> = nil
        private var avail_out : CUnsignedInt = 0
        private var total_out : CUnsignedLong = 0
        
        private var msg : UnsafePointer<CChar> = nil
        private var state : COpaquePointer = nil
        
        private var zalloc : COpaquePointer = nil
        private var zfree : COpaquePointer = nil
        private var opaque : COpaquePointer = nil
        
        private var data_type : CInt = 0
        private var adler : CUnsignedLong = 0
        private var reserved : CUnsignedLong = 0
    }
    
    @_silgen_name("zlibVersion") private static func zlibVersion() -> COpaquePointer
    @_silgen_name("deflateInit2_") private func deflateInit2(strm : UnsafeMutablePointer<Void>, level : CInt, method : CInt, windowBits : CInt, memLevel : CInt, strategy : CInt, version : COpaquePointer, stream_size : CInt) -> CInt
    @_silgen_name("deflateInit_") private func deflateInit(strm : UnsafeMutablePointer<Void>, level : CInt, version : COpaquePointer, stream_size : CInt) -> CInt
    @_silgen_name("deflateEnd") private func deflateEnd(strm : UnsafeMutablePointer<Void>) -> CInt
    @_silgen_name("deflate") private func deflate(strm : UnsafeMutablePointer<Void>, flush : CInt) -> CInt
    @_silgen_name("inflateInit2_") private func inflateInit2(strm : UnsafeMutablePointer<Void>, windowBits : CInt, version : COpaquePointer, stream_size : CInt) -> CInt
    @_silgen_name("inflateInit_") private func inflateInit(strm : UnsafeMutablePointer<Void>, version : COpaquePointer, stream_size : CInt) -> CInt
    @_silgen_name("inflate") private func inflate(strm : UnsafeMutablePointer<Void>, flush : CInt) -> CInt
    @_silgen_name("inflateEnd") private func inflateEnd(strm : UnsafeMutablePointer<Void>) -> CInt
    
    private static var c_version : COpaquePointer = ZStream.zlibVersion()
    private(set) static var version : String = String(format: "%s", locale: nil, c_version)
    
    private func makeError(res : CInt) -> NSError? {
        var err = ""
        switch res {
        case 0: return nil
        case 1: err = "stream end"
        case 2: err = "need dict"
        case -1: err = "errno"
        case -2: err = "stream error"
        case -3: err = "data error"
        case -4: err = "mem error"
        case -5: err = "buf error"
        case -6: err = "version error"
        default: err = "undefined error"
        }
        return NSError(domain: "deflateswift", code: -1, userInfo: [NSLocalizedDescriptionKey:err])
    }
    
    private var strm = z_stream()
    private var deflater = true
    private var initd = false
    private var init2 = false
    private var level = CInt(-1)
    private var windowBits = CInt(15)
    private var out = [UInt8](count: 5000, repeatedValue: 0)
    public init() { }
    public func write(var bytes : [UInt8], flush: Bool) -> (bytes: [UInt8], err: NSError?){
        //var bytes = bytesLet
        var res : CInt
        if !initd {
            if deflater {
                if init2 {
                    res = deflateInit2(&strm, level: level, method: 8, windowBits: windowBits, memLevel: 8, strategy: 0, version: ZStream.c_version, stream_size: CInt(sizeof(z_stream)))
                } else {
                    res = deflateInit(&strm, level: level, version: ZStream.c_version, stream_size: CInt(sizeof(z_stream)))
                }
            } else {
                if init2 {
                    res = inflateInit2(&strm, windowBits: windowBits, version: ZStream.c_version, stream_size: CInt(sizeof(z_stream)))
                } else {
                    res = inflateInit(&strm, version: ZStream.c_version, stream_size: CInt(sizeof(z_stream)))
                }
            }
            if res != 0{
                return ([UInt8](), makeError(res))
            }
            initd = true
        }
        var result = [UInt8]()
        strm.avail_in = CUnsignedInt(bytes.count)
        strm.next_in = &bytes+0
        repeat {
            strm.avail_out = CUnsignedInt(out.count)
            strm.next_out = &out+0
            if deflater {
                res = deflate(&strm, flush: flush ? 1 : 0)
            } else {
                res = inflate(&strm, flush: flush ? 1 : 0)
            }
            if res < 0 {
                return ([UInt8](), makeError(res))
            }
            let have = out.count - Int(strm.avail_out)
            if have > 0 {
                result += Array(out[0...have-1])
            }
        } while (strm.avail_out == 0 && res != 1)
        if strm.avail_in != 0 {
            return ([UInt8](), makeError(-9999))
        }
        return (result, nil)
    }
    deinit{
        if initd{
            if deflater {
                deflateEnd(&strm)
            } else {
                inflateEnd(&strm)
            }
        }
    }
}

public class DeflateStream : ZStream {
    convenience public init(level : Int){
        self.init()
        self.level = CInt(level)
    }
    convenience public init(windowBits: Int){
        self.init()
        self.init2 = true
        self.windowBits = CInt(windowBits)
    }
    convenience public init(level : Int, windowBits: Int){
        self.init()
        self.init2 = true
        self.level = CInt(level)
        self.windowBits = CInt(windowBits)
    }
}

public class InflateStream : ZStream {
    override public init(){
        super.init()
        deflater = false
    }
    convenience public init(windowBits: Int){
        self.init()
        self.init2 = true
        self.windowBits = CInt(windowBits)
    }
}