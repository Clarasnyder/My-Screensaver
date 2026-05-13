#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <ApplicationServices/ApplicationServices.h>

@interface ScreensaverAppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSMutableArray<NSWindow *> *windows;
@property(nonatomic, strong) id localMonitor;
@property(nonatomic, strong) id globalMonitor;
@end

@implementation ScreensaverAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  (void)notification;

  self.windows = [NSMutableArray array];
  [NSApp setPresentationOptions:NSApplicationPresentationHideDock |
                                NSApplicationPresentationHideMenuBar |
                                NSApplicationPresentationDisableProcessSwitching |
                                NSApplicationPresentationDisableForceQuit |
                                NSApplicationPresentationDisableSessionTermination];

  for (NSScreen *screen in NSScreen.screens) {
    [self createWindowForScreen:screen];
  }

  [NSCursor hide];
  [NSApp activateIgnoringOtherApps:YES];
  [self installDismissMonitors];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  (void)notification;
  [NSCursor unhide];

  if (self.localMonitor) {
    [NSEvent removeMonitor:self.localMonitor];
  }

  if (self.globalMonitor) {
    [NSEvent removeMonitor:self.globalMonitor];
  }
}

- (void)createWindowForScreen:(NSScreen *)screen {
  NSWindow *window = [[NSWindow alloc] initWithContentRect:screen.frame
                                                 styleMask:NSWindowStyleMaskBorderless
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO
                                                    screen:screen];
  window.backgroundColor = NSColor.blackColor;
  window.opaque = YES;
  window.level = CGShieldingWindowLevel();
  window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces |
                              NSWindowCollectionBehaviorStationary |
                              NSWindowCollectionBehaviorFullScreenAuxiliary;
  window.releasedWhenClosed = NO;

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  WKWebView *webView = [[WKWebView alloc] initWithFrame:window.contentView.bounds configuration:configuration];
  webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [webView setValue:@NO forKey:@"drawsBackground"];

  NSURL *htmlURL = [NSBundle.mainBundle URLForResource:@"index" withExtension:@"html"];
  if (htmlURL && NSBundle.mainBundle.resourceURL) {
    [webView loadFileURL:htmlURL allowingReadAccessToURL:NSBundle.mainBundle.resourceURL];
  }

  [window.contentView addSubview:webView];
  [window makeKeyAndOrderFront:nil];
  [self.windows addObject:window];
}

- (void)installDismissMonitors {
  NSEventMask mask = NSEventMaskKeyDown |
                     NSEventMaskLeftMouseDown |
                     NSEventMaskRightMouseDown |
                     NSEventMaskOtherMouseDown |
                     NSEventMaskScrollWheel |
                     NSEventMaskMouseMoved |
                     NSEventMaskLeftMouseDragged |
                     NSEventMaskRightMouseDragged |
                     NSEventMaskOtherMouseDragged;

  __weak typeof(self) weakSelf = self;
  self.localMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:mask handler:^NSEvent *(NSEvent *event) {
    [weakSelf dismiss];
    return event;
  }];

  self.globalMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:^(NSEvent *event) {
    (void)event;
    [weakSelf dismiss];
  }];
}

- (void)dismiss {
  [NSApp terminate:nil];
}

@end

int main(int argc, const char *argv[]) {
  (void)argc;
  (void)argv;

  @autoreleasepool {
    NSApplication *application = NSApplication.sharedApplication;
    ScreensaverAppDelegate *delegate = [[ScreensaverAppDelegate alloc] init];
    application.delegate = delegate;
    [application run];
  }

  return 0;
}
