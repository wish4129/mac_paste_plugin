#include "include/window_paste_plugin/window_paste_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

namespace {

class WindowPastePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WindowPastePlugin();

  virtual ~WindowPastePlugin();

 private:
  // Add necessary methods and variables for Windows implementation
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void WindowPastePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "window_paste_plugin",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowPastePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowPastePlugin::WindowPastePlugin() {}

WindowPastePlugin::~WindowPastePlugin() {}

void WindowPastePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("start") == 0) {
    // Implement start logic
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("stop") == 0) {
    // Implement stop logic
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void WindowPastePluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  WindowPastePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}