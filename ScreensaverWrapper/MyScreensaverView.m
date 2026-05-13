#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

@interface MyScreensaverView : ScreenSaverView
@property(nonatomic, strong) WKWebView *webView;
@end

@implementation MyScreensaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    [self setAnimationTimeInterval:1.0 / 30.0];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.suppressesIncrementalRendering = NO;

    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    _webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _webView.wantsLayer = YES;
    _webView.layer.backgroundColor = NSColor.blackColor.CGColor;
    [_webView setValue:@NO forKey:@"drawsBackground"];

    [self addSubview:_webView];
    [self loadScreensaverHTML];
  }

  return self;
}

- (void)loadScreensaverHTML {
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  NSURL *htmlURL = [bundle URLForResource:@"index" withExtension:@"html"];
  NSURL *resourcesURL = bundle.resourceURL;

  if (htmlURL && resourcesURL) {
    [self.webView loadFileURL:htmlURL allowingReadAccessToURL:resourcesURL];
  }
}

- (void)startAnimation {
  [super startAnimation];
  [self loadScreensaverHTML];
}

- (BOOL)hasConfigureSheet {
  return NO;
}

- (NSWindow *)configureSheet {
  return nil;
}

@end
