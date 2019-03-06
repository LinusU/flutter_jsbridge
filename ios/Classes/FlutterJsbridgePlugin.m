#import "FlutterJsbridgePlugin.h"
#import <flutter_jsbridge/flutter_jsbridge-Swift.h>

@implementation FlutterJsbridgePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterJsbridgePlugin registerWithRegistrar:registrar];
}
@end
