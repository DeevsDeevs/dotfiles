#include <CoreAudio/CoreAudio.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void fail_with_osstatus(const char* context, OSStatus status) {
  fprintf(stderr, "%s failed: %d\n", context, (int)status);
  exit(1);
}

static CFStringRef copy_device_name(AudioDeviceID device_id) {
  AudioObjectPropertyAddress address = {
    .mSelector = kAudioObjectPropertyName,
    .mScope = kAudioObjectPropertyScopeGlobal,
    .mElement = kAudioObjectPropertyElementMain
  };

  CFStringRef name = NULL;
  UInt32 size = sizeof(name);
  OSStatus status = AudioObjectGetPropertyData(device_id,
                                               &address,
                                               0,
                                               NULL,
                                               &size,
                                               &name);
  if (status != noErr) return NULL;
  return name;
}

static bool device_has_output(AudioDeviceID device_id) {
  AudioObjectPropertyAddress address = {
    .mSelector = kAudioDevicePropertyStreams,
    .mScope = kAudioDevicePropertyScopeOutput,
    .mElement = kAudioObjectPropertyElementWildcard
  };

  UInt32 size = 0;
  OSStatus status = AudioObjectGetPropertyDataSize(device_id,
                                                   &address,
                                                   0,
                                                   NULL,
                                                   &size);
  return status == noErr && size >= sizeof(AudioStreamID);
}

static AudioDeviceID get_default_output_device() {
  AudioObjectPropertyAddress address = {
    .mSelector = kAudioHardwarePropertyDefaultOutputDevice,
    .mScope = kAudioObjectPropertyScopeGlobal,
    .mElement = kAudioObjectPropertyElementMain
  };

  AudioDeviceID device_id = kAudioObjectUnknown;
  UInt32 size = sizeof(device_id);
  OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                               &address,
                                               0,
                                               NULL,
                                               &size,
                                               &device_id);
  if (status != noErr) fail_with_osstatus("reading default output device", status);
  return device_id;
}

static void set_default_device(AudioObjectPropertySelector selector, AudioDeviceID device_id) {
  AudioObjectPropertyAddress address = {
    .mSelector = selector,
    .mScope = kAudioObjectPropertyScopeGlobal,
    .mElement = kAudioObjectPropertyElementMain
  };

  UInt32 size = sizeof(device_id);
  OSStatus status = AudioObjectSetPropertyData(kAudioObjectSystemObject,
                                               &address,
                                               0,
                                               NULL,
                                               size,
                                               &device_id);
  if (status != noErr) fail_with_osstatus("setting default device", status);
}

static void print_output_devices() {
  AudioObjectPropertyAddress address = {
    .mSelector = kAudioHardwarePropertyDevices,
    .mScope = kAudioObjectPropertyScopeGlobal,
    .mElement = kAudioObjectPropertyElementMain
  };

  UInt32 size = 0;
  OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject,
                                                   &address,
                                                   0,
                                                   NULL,
                                                   &size);
  if (status != noErr) fail_with_osstatus("reading audio devices size", status);

  UInt32 count = size / sizeof(AudioDeviceID);
  AudioDeviceID* devices = calloc(count, sizeof(AudioDeviceID));
  if (!devices) exit(1);

  status = AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                      &address,
                                      0,
                                      NULL,
                                      &size,
                                      devices);
  if (status != noErr) {
    free(devices);
    fail_with_osstatus("reading audio devices", status);
  }

  AudioDeviceID current = get_default_output_device();

  for (UInt32 i = 0; i < count; ++i) {
    AudioDeviceID device_id = devices[i];
    if (!device_has_output(device_id)) continue;

    CFStringRef name = copy_device_name(device_id);
    if (!name) continue;

    char buffer[1024];
    if (CFStringGetCString(name, buffer, sizeof(buffer), kCFStringEncodingUTF8)) {
      printf("%d\t%u\t%s\n", device_id == current ? 1 : 0, (unsigned int)device_id, buffer);
    }
    CFRelease(name);
  }

  free(devices);
}

static void set_output_device_from_arg(const char* arg) {
  char* end = NULL;
  unsigned long parsed = strtoul(arg, &end, 10);
  if (!arg[0] || !end || *end != '\0') {
    fprintf(stderr, "invalid device id: %s\n", arg);
    exit(1);
  }

  AudioDeviceID device_id = (AudioDeviceID)parsed;
  set_default_device(kAudioHardwarePropertyDefaultOutputDevice, device_id);
  set_default_device(kAudioHardwarePropertyDefaultSystemOutputDevice, device_id);
}

int main(int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s list | set <device-id>\n", argv[0]);
    return 1;
  }

  if (strcmp(argv[1], "list") == 0) {
    print_output_devices();
    return 0;
  }

  if (strcmp(argv[1], "set") == 0 && argc == 3) {
    set_output_device_from_arg(argv[2]);
    return 0;
  }

  fprintf(stderr, "Usage: %s list | set <device-id>\n", argv[0]);
  return 1;
}
