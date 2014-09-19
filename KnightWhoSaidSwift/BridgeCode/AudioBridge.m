//
//  AudioBridge.m
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 09.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

/**
 lesson learned:
 - include this file before any other #import
 - *.mm files are not supported!
 */

#import "KnightWhoSaidSwift-Swift.h"
#import "AudioBridge.h"

static UInt32 gBufferSizeBytes = 0x10000; // 64k
static const NSInteger numQueue = 3;

AudioQueueBufferRef buffers[numQueue];
AudioStreamBasicDescription		dataFormat;
AudioStreamPacketDescription	*packetDescs;
AudioFileID audioFile;
AudioQueueRef  queue;

UInt64 packetIndex = 0;
UInt32 numPacketsToRead = 0;
bool repeatSong = false;

UInt32 readPacketsIntoBuffer(AudioQueueBufferRef buffer)
{
    UInt32		numBytes, numPackets;
    
    // read packets into buffer from file
    numPackets = numPacketsToRead;
    AudioFileReadPackets(audioFile, NO, &numBytes, packetDescs, packetIndex, &numPackets, buffer->mAudioData);
    
    if (numPackets > 0)
    {
        // - End Of File has not been reached yet since we read some packets, so enqueue the buffer we just read into
        // the audio queue, to be played next
        // - (packetDescs ? numPackets : 0) means that if there are packet descriptions (which are used only for Variable
        // BitRate data (VBR)) we'll have to send one for each packet, otherwise zero
        buffer->mAudioDataByteSize = numBytes;
        AudioQueueEnqueueBuffer(queue, buffer, (packetDescs ? numPackets : 0), packetDescs);
        
        // move ahead to be ready for next time we need to read from the file
        packetIndex += numPackets;
    }
    
    return numPackets;
}

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer)
{

    if (readPacketsIntoBuffer(buffer) == 0)
    {
        // End Of File reached, so rewind and refill the buffer using the beginning of the file instead
        packetIndex = 0;
        readPacketsIntoBuffer(buffer);
        
        // if not repeating then we'll pause it so it's ready to play again immediately if needed
        if (!repeatSong)
        {
            AudioQueuePause(queue);
        }
    }
}

void InitializeAudioSource(void *userAudioClass)
{
    KWSBackgroundStreamPlayer *BackgroundPlayer = (__bridge KWSBackgroundStreamPlayer*)userAudioClass;

    NSString *path = BackgroundPlayer.filePath;
    repeatSong = BackgroundPlayer.repeat;
    
    if (path == nil) return;
    
    UInt32 allowMixing = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32		size, maxPacketSize;
    char		*cookie;
    int			i;
    
    if (noErr != AudioFileOpenURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], 0x01, kAudioFileCAFType, &audioFile))
    {
        NSLog(@"GBMusicTrack Error - initWithPath: could not open audio file. Path given was: %@", path);
    }
    
    size = sizeof(dataFormat);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &size, &dataFormat);
    OSStatus result = AudioQueueNewOutput(&dataFormat, BufferCallback, (__bridge void *)(BackgroundPlayer), nil, nil, 0, &queue);
    
    if (result != noErr) {
        
        NSLog(@"ERROR: %d",result);
    }
   
    // calculate number of packets to read and allocate space for packet descriptions if needed
    if (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0)
    {
        // since we didn't get sizes to work with, then this must be VBR data (Variable BitRate), so
        // we'll have to ask Core Audio to give us a conservative estimate of the largest packet we are
        // likely to read with kAudioFilePropertyPacketSizeUpperBound
        size = sizeof(maxPacketSize);
        
        AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        
        if (maxPacketSize > gBufferSizeBytes)
        {
            // hmm... well, we don't want to go over our buffer size, so we'll have to limit it I guess
            maxPacketSize = gBufferSizeBytes;
            NSLog(@"GBMusicTrack Warning - initWithPath: had to limit packet size requested for file path: %@", path);
        }
        
        numPacketsToRead = gBufferSizeBytes / maxPacketSize;
        
        // will need a packet description for each packet since this is VBR data, so allocate space accordingly
        packetDescs = (AudioStreamPacketDescription	*)malloc(sizeof(AudioStreamPacketDescription) * numPacketsToRead);
    }
    else
    {
        // for CBR data (Constant BitRate), we can simply fill each buffer with as many packets as will fit
        numPacketsToRead = gBufferSizeBytes / dataFormat.mBytesPerPacket;
        
        // don't need packet descriptsions for CBR data
        packetDescs = nil;
    }
    
    // see if file uses a magic cookie (a magic cookie is meta data which some formats use)
    AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyMagicCookieData, &size, nil);
   
    if (size > 0)
    {
        // copy the cookie data from the file into the audio queue
        cookie = (char*)malloc(sizeof(char) * size);
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
        AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, cookie, size);
        free(cookie);
    }
    
    // allocate and prime buffers with some data
    packetIndex = 0;
    
    for (i = 0; i < numQueue; i++)
    {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);
        
        if (readPacketsIntoBuffer(buffers[i]) == 0)
        {
            // this might happen if the file was so short that it needed less buffers than we planned on using
            break;
        }
    }
    
}

void PlayAudio()
{
    AudioQueueStart(queue, nil);
}

void PauseAudio()
{
    AudioQueuePause(queue);
}

void CloseAudio()
{
    AudioQueueStop(queue, YES);
    AudioQueueDispose(queue, YES);
    AudioFileClose(audioFile);
}

void SetAudioGain(Float32 gain)
{
    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, gain);
}
