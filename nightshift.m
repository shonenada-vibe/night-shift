#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <stdio.h>
#import <string.h>

@interface CBBlueLightClient : NSObject
- (BOOL)setEnabled:(BOOL)enabled;
@end

void print_usage() {
    printf("Usage: nightshift [on|off]\n");
    printf("       Default is 'on'.\n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Explicitly load the framework
        void *handle = dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_LAZY);
        if (!handle) {
            printf("Error: Could not load CoreBrightness framework: %s\n", dlerror());
            return 1;
        }

        Class clientClass = NSClassFromString(@"CBBlueLightClient");
        if (!clientClass) {
            printf("Error: CBBlueLightClient class not found.\n");
            return 1;
        }
        
        id client = [[clientClass alloc] init];
        
        NSString *action = @"on";
        if (argc > 1) {
            action = [NSString stringWithUTF8String:argv[1]].lowercaseString;
        }
        
        if ([action isEqualToString:@"on"] || [action isEqualToString:@"enable"]) {
            BOOL success = [client setEnabled:YES];
            if (success) printf("Night Shift enabled.\n");
            else printf("Night Shift enable command sent (no change or failed).\n");
        } else if ([action isEqualToString:@"off"] || [action isEqualToString:@"disable"]) {
            BOOL success = [client setEnabled:NO];
            if (success) printf("Night Shift disabled.\n");
            else printf("Night Shift disable command sent (no change or failed).\n");
        } else {
            print_usage();
            return 1;
        }
    }
    return 0;
}
