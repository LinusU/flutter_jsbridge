package com.linusu.flutter_jsbridge

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterJsbridgePlugin: MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_jsbridge")
      channel.setMethodCallHandler(FlutterJsbridgePlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    result.notImplemented()
  }
}
