#import <Cocoa/Cocoa.h>
#import <dlfcn.h>
#import <stdio.h>
#import <string.h>

@interface CBBlueLightClient : NSObject
- (BOOL)setEnabled:(BOOL)enabled;
- (BOOL)getBlueLightStatus:(void *)status;
@end

typedef struct {
    int hour;
    int minute;
} Time;

typedef struct {
    Time fromTime;
    Time toTime;
} Schedule;

typedef struct {
    BOOL active;
    BOOL enabled;
    BOOL sunSchedulePermitted;
    int mode;
    Schedule schedule;
    unsigned long long disableFlags;
} StatusData;

// MARK: - Menu Bar Controller

@interface NightShiftController : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) CBBlueLightClient *blueLightClient;
@property (nonatomic, strong) NSMenuItem *toggleItem;
@end

@implementation NightShiftController

- (instancetype)initWithClient:(CBBlueLightClient *)client {
    self = [super init];
    if (self) {
        _blueLightClient = client;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.font = [NSFont systemFontOfSize:14];

    NSMenu *menu = [[NSMenu alloc] init];

    self.toggleItem = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(toggleNightShift:) keyEquivalent:@""];
    self.toggleItem.target = self;
    [menu addItem:self.toggleItem];

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@"q"];
    quitItem.target = self;
    [menu addItem:quitItem];

    self.statusItem.menu = menu;

    [self updateStatus];
}

- (BOOL)isNightShiftEnabled {
    StatusData status;
    memset(&status, 0, sizeof(StatusData));
    [self.blueLightClient getBlueLightStatus:&status];
    return status.enabled;
}

- (void)updateStatus {
    BOOL enabled = [self isNightShiftEnabled];
    self.statusItem.button.title = enabled ? @"🌙" : @"☀️";
    self.toggleItem.title = enabled ? @"Turn Off Night Shift" : @"Turn On Night Shift";
}

- (void)toggleNightShift:(id)sender {
    BOOL currentlyEnabled = [self isNightShiftEnabled];
    [self.blueLightClient setEnabled:!currentlyEnabled];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateStatus];
    });
}

- (void)quit:(id)sender {
    [NSApp terminate:nil];
}

@end

// MARK: - CLI

void print_usage() {
    printf("Usage: nightshift [on|off]\n");
    printf("       No arguments launches the menu bar app.\n");
}

int run_cli(CBBlueLightClient *client, NSString *action) {
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
    return 0;
}

// MARK: - Main

int main(int argc, const char * argv[]) {
    @autoreleasepool {
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

        CBBlueLightClient *client = [[clientClass alloc] init];

        if (argc > 1) {
            NSString *action = [NSString stringWithUTF8String:argv[1]].lowercaseString;
            return run_cli(client, action);
        }

        // No arguments: launch menu bar app
        NSApplication *app = [NSApplication sharedApplication];
        NightShiftController *controller = [[NightShiftController alloc] initWithClient:client];
        app.delegate = controller;
        [app run];
    }
    return 0;
}
