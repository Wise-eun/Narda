import UIKit
import Flutter
import TMapSDK
import MapKit

@UIApplicationMain


@objc class AppDelegate: FlutterAppDelegate,  TMapTapiDelegate{
let appKey:String = "yIvsQzTPnWa2bnrbh6HeN9iq4CbOhadO3M3g46RT";

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
  let channel = FlutterMethodChannel(name:"mobile/parameters", binaryMessenger:
  controller.binaryMessenger)

  channel.setMethodCallHandler({
  [weak self]  (call:FlutterMethodCall, result : FlutterResult) -> Void in

  switch (call.method){
    case "initTmapAPI":
        self?.initTmapAPI()
        result("initTmapAPI")
        break;
    case "isTmapApplicationInstalled":
        if(TMapApi.isTmapApplicationInstalled())
        {
            let url = TMapApi.getTMapDownUrl()
                        result(url)
        }
        else
        {

            result("")
        }
        break;
  default:
    result(FlutterMethodNotImplemented)
    break;
  }
  })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}

  private func initTmapAPI(){
  TMapApi.setSKTMapAuthenticationWithDelegate(self,apiKey:appKey)
  }
}
