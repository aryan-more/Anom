#include "flutter_window.h"
#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <optional>
#include <fstream>
#include <thread>
#include "flutter/generated_plugin_registrant.h"
#include <Windows.h>
#ifdef _WIN32
#include <io.h>
#define access _access_s
#else
#include <unistd.h>
#endif

bool FileExists(const std::string &Filename)
{
  return access(Filename.c_str(), 0) == 0;
}
FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project)
{
}

std::wstring GetHostPath()
{
  TCHAR infoBuf[32767];
  if (!GetSystemDirectory(infoBuf, 32767))
  {
    throw std::runtime_error::exception("Unable To Get System Directory");
  }
  // Usually the hosts file is stored at C:\Windows\system32\drivers\etc\hosts
  // The location of the host file drive is depends on which drive windows is installed
  return std::wstring(&infoBuf[0]) + std::wstring(L"\\drivers\\etc\\hosts");
}

FlutterWindow::~FlutterWindow() {}
void initMethodChannel(flutter::FlutterEngine *flutter_instance)
{
  const static std::string channel_name("anom");

  auto channel =
      std::make_unique<flutter::MethodChannel<>>(
          flutter_instance->messenger(), channel_name,
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<> &call,
         std::unique_ptr<flutter::MethodResult<>> result)
      {
        // Use data folder during release build and use build folder during debug
        //std::string asset_path = "build\\flutter_assets\\assets\\";
        std::string asset_path = "data\\flutter_assets\\assets\\";
        std::string path;

        if (call.method_name().compare("privacy") == 0)
        {
          std::string subject, line;
          auto args = *call.arguments();
          std::fstream file;
          std::vector<std::string> simple;
          try
          {
            std::vector<std::string> websites;

            std::vector<flutter::EncodableValue> arguments = (std::get<std::vector<flutter::EncodableValue>>(args));
            for (size_t i = 0; i < arguments.size(); i++)
            {
              subject = std::get<std::string>(arguments[i]);
              path = asset_path + subject;
              bool x = FileExists(path);
              file.open(path, std::ios::in);
              simple.push_back(subject);
              if (!x)
              {
                result->Error("Unable To Load Assets File " + asset_path + subject);
              }
              while (std::getline(file, line))
              {
                websites.push_back(line);
              }
              file.close();
            }

            file.open(GetHostPath(), std::ios::out);
            if (file.is_open())
            {
              file << "# This File is Edited By Anom" << std::endl;
              for (int i = 0; i < websites.size(); i++)
              {
                file << "0.0.0.0 " << websites[i] << std::endl;
              }
              result->Success((std::string) "Success");
            }

            return;
          }
          catch (const std::runtime_error &e)
          {

            result->Error((std::string)e.what());
          }
          catch (const std::exception &e)
          {
            result->Error((std::string)e.what());
            return;
          }
        }
        result->NotImplemented();
      });
}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());

  initMethodChannel(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
