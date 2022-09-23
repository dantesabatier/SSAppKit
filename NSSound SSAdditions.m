//
//  NSSound+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/09/13.
//
//

#import "NSSound+SSAdditions.h"
#import <SSBase/SSDefines.h>
#import <CoreAudio/CoreAudio.h>

@implementation NSSound (SSAdditions)

+ (instancetype)alertSoundNamed:(NSString *)name {
    AudioDeviceID deviceID = 0;
    UInt32 size = sizeof(AudioDeviceID);
    
    // get the system default audio output device …
    AudioObjectPropertyAddress address = {
        kAudioHardwarePropertyDefaultSystemOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, &deviceID);
    if (status != noErr) {
        return nil;
    }
    
    // … then, since one exists, get the unique identifier …
    UInt32 stringSize = sizeof(CFStringRef);
    CFStringRef deviceUniqueIdentifier = NULL;
    
    address.mSelector = kAudioDevicePropertyDeviceUID;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMaster;
    
    status = AudioObjectGetPropertyData(deviceID, &address, 0, NULL, &stringSize, &deviceUniqueIdentifier);
    if (status != noErr) {
        return nil;
    }
	NSSound *sound = [NSSound soundNamed:name];
    sound.playbackDeviceIdentifier = (__bridge NSString *)SSAutorelease(deviceUniqueIdentifier);
	return sound;
}

@end
