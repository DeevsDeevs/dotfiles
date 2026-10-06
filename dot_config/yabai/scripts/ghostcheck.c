#include <CoreGraphics/CoreGraphics.h>
#include <stdio.h>

int main(void) {
    CFArrayRef wins = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    for (CFIndex i = 0; i < CFArrayGetCount(wins); i++) {
        CFDictionaryRef w = CFArrayGetValueAtIndex(wins, i);
        CFStringRef owner = CFDictionaryGetValue(w, kCGWindowOwnerName);
        char name[256] = "?";
        if (owner) CFStringGetCString(owner, name, sizeof(name), kCFStringEncodingUTF8);
        CFNumberRef pidRef = CFDictionaryGetValue(w, kCGWindowOwnerPID);
        CFNumberRef numRef = CFDictionaryGetValue(w, kCGWindowNumber);
        int pid = 0, num = 0;
        if (pidRef) CFNumberGetValue(pidRef, kCFNumberIntType, &pid);
        if (numRef) CFNumberGetValue(numRef, kCFNumberIntType, &num);
        CFDictionaryRef boundsRef = CFDictionaryGetValue(w, kCGWindowBounds);
        CGRect r = CGRectZero;
        if (boundsRef) CGRectMakeWithDictionaryRepresentation(boundsRef, &r);
        printf("%s|pid=%d|win=%d|%.0fx%.0f@%.0f,%.0f\n", name, pid, num, r.size.width, r.size.height, r.origin.x, r.origin.y);
    }
    return 0;
}
