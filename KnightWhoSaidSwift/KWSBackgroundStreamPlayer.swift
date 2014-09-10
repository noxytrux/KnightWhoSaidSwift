//
//  KWSBackgroundStreamPlayer.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 08.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

//TODO: test after it will compile

import UIKit
import AudioToolbox

let KWSMusicTrackFinishedPlayingNotification : String! = "KWSMusicTrackFinishedPlayingNotification"

class KWSBackgroundStreamPlayer: NSObject {
   
    private let bufferSizeBytes : UInt32 = 0x10000;
    private let numQueueBuffers = 3
    private var audioFile : AudioFileID = COpaquePointer.null()
    private var audioFormat : AudioStreamBasicDescription
    private var audioQueue : AudioQueue?
    private var packetIndex : Int64
    private var numPacketsToRead : UInt32
    private var packetDescs : UnsafeMutablePointer<AudioStreamPacketDescription> = UnsafeMutablePointer<AudioStreamPacketDescription>.convertFromNilLiteral()
    private var trackClosed : Bool
    private var buffers : Array<AudioQueueBufferRef>
    
    internal var repeat : Bool
    
    override init() {
        
        self.audioFormat = AudioStreamBasicDescription(
            mSampleRate: 0,
            mFormatID: 0,
            mFormatFlags: 0,
            mBytesPerPacket: 0,
            mFramesPerPacket: 0,
            mBytesPerFrame: 0,
            mChannelsPerFrame: 0,
            mBitsPerChannel: 0,
            mReserved: 0)

        self.packetIndex = 0
        self.numPacketsToRead = 0
        self.trackClosed = false
        self.buffers = Array<AudioQueueBufferRef>(count: self.numQueueBuffers, repeatedValue: AudioQueueBufferRef())
        self.repeat = false
        
        super.init()
    }
    
    func loadFromPath(path : String!) {
        
        if path == nil {
            return
        }
        
        var size : UInt32 = UInt32(sizeof(AudioStreamBasicDescription))
        var maxPacketSize : UInt32 = 0
        var cookie : UnsafeMutablePointer<CChar>
        var i : Int16
        
        if noErr != AudioFileOpenURL(NSURL.fileURLWithPath(path), 0x01, AudioFileTypeID(kAudioFileCAFType), &self.audioFile) {
            
            println("Error - could not open audio file. Path given was: \(path)")
            return
        }
        
        var audioPointer : Unmanaged<AudioQueue>?

        //THIS IS BROKEN:
        var bufferCallBackProc : AudioQueueOutputCallback = AudioQueueOutputCallback.convertFromNilLiteral() //BufferCallback
        
        //THIS IS HACK
        var unsafeSelf : UnsafeMutablePointer<KWSBackgroundStreamPlayer> = UnsafeMutablePointer<KWSBackgroundStreamPlayer>.alloc(sizeof(KWSBackgroundStreamPlayer))
            unsafeSelf.initialize(self)
        var dataPointer : COpaquePointer = COpaquePointer(unsafeSelf)
        var voidSelf : UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>(dataPointer)
        
        AudioFileGetProperty(self.audioFile, AudioFilePropertyID(kAudioFilePropertyDataFormat), &size, &self.audioFormat)
        AudioQueueNewOutput(&self.audioFormat, bufferCallBackProc, voidSelf, nil, nil, 0, &audioPointer)
        
        self.audioQueue = audioPointer!.takeUnretainedValue()
        
        if (self.audioFormat.mBytesPerPacket == 0 || self.audioFormat.mFramesPerPacket == 0) {
            
            size = UInt32(sizeofValue(maxPacketSize))
            
            AudioFileGetProperty(audioFile, AudioFilePropertyID(kAudioFilePropertyPacketSizeUpperBound), &size, &maxPacketSize)
            
            if maxPacketSize > bufferSizeBytes {
                
                maxPacketSize = bufferSizeBytes
                println("\(self) Warning - loadFromPath: had to limit packet size requested for file path: \(path)")
            }
            
            self.numPacketsToRead = bufferSizeBytes / maxPacketSize
            
            packetDescs = UnsafeMutablePointer<AudioStreamPacketDescription>.alloc(Int(self.numPacketsToRead))
        }
        else
        {
            numPacketsToRead = bufferSizeBytes / self.audioFormat.mBytesPerPacket
            packetDescs = nil
        }
        
        // see if file uses a magic cookie (a magic cookie is meta data which some formats use)
        AudioFileGetPropertyInfo(audioFile, AudioFilePropertyID(kAudioFilePropertyMagicCookieData), &size, nil)
        
        if (size > 0)
        {
            // copy the cookie data from the file into the audio queue
            cookie = UnsafeMutablePointer<CChar>.alloc(Int(size))
            
            AudioFileGetProperty(self.audioFile, AudioFilePropertyID(kAudioFilePropertyMagicCookieData), &size, cookie)
            AudioQueueSetProperty(self.audioQueue, AudioFilePropertyID(kAudioQueueProperty_MagicCookie), cookie, size)
        
            cookie.destroy(Int(size))
        }
        
        // allocate and prime buffers with some data
        packetIndex = 0;
        
        for (var i = 0; i < self.numQueueBuffers; i++)
        {
            AudioQueueAllocateBuffer(self.audioQueue, bufferSizeBytes, &self.buffers[i])
            
            if self.readPacketsIntoBuffer(self.buffers[i]) == 0 {
                break;
            }
        }
        
        self.repeat = false;
        self.trackClosed = false;
    }
    
    func setGain(#gain : Float32) {
        
        AudioQueueSetParameter(self.audioQueue, AudioQueueParameterID(kAudioQueueParam_Volume), gain)
    }
    
    func play() {
    
        AudioQueueStart(self.audioQueue, nil)
    }
    
    func pause() {
    
        AudioQueuePause(self.audioQueue)
    }
    
    func close() {
    
        if self.trackClosed == true {
        
            return
        }
        
        self.trackClosed = true
        AudioQueueStop(self.audioQueue, true)
        AudioQueueDispose(self.audioQueue, true)
        AudioFileClose(self.audioFile)
    }
    
    func callbackForBuffer(buffer:AudioQueueBufferRef) {
        
        if self.readPacketsIntoBuffer(buffer) == 0 {
            
            packetIndex = 0;
            self.readPacketsIntoBuffer(buffer)
            
            if !self.repeat {
                
                AudioQueuePause(self.audioQueue);
                
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    
                    self.postTrackFinishedPlayingNotification()
                })
            }
        }
    
    }
    
    func postTrackFinishedPlayingNotification() {
    
        NSNotificationCenter.defaultCenter().postNotificationName(KWSMusicTrackFinishedPlayingNotification, object: self)
    }
    
    func readPacketsIntoBuffer(buffer:AudioQueueBufferRef) -> UInt32 {
    
        var numBytes : UInt32 = 0,
            numPackets : UInt32 = 0
        
        numPackets = self.numPacketsToRead
        
        AudioFileReadPackets(self.audioFile, false, &numBytes, packetDescs, packetIndex, &numPackets, buffer.memory.mAudioData)
        
        if numPackets > 0 {
            
            buffer.memory.mAudioDataByteSize = numBytes
            AudioQueueEnqueueBuffer(self.audioQueue, buffer, (packetDescs != nil ? numPackets : 0), packetDescs)
            
            self.packetIndex += Int64(numPackets);
        }
        
        return numPackets;
    }
    
    deinit {
        
        self.close()
    }
    
}
