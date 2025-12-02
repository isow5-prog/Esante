import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "esante/gallery",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard call.method == "saveImageToGallery" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard let args = call.arguments as? FlutterStandardTypedData else {
        result(FlutterError(code: "ARG_ERROR", message: "Bytes manquants", details: nil))
        return
      }

      self?.saveImageToPhotos(bytes: args.data, result: result)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveImageToPhotos(bytes: Data, result: @escaping FlutterResult) {
    PHPhotoLibrary.requestAuthorization { status in
      if status == .authorized || status == .limited {
        PHPhotoLibrary.shared().performChanges({
          let options = PHAssetResourceCreationOptions()
          let creationRequest = PHAssetCreationRequest.forAsset()
          creationRequest.addResource(with: .photo, data: bytes, options: options)
        }) { success, error in
          if success {
            result(true)
          } else {
            result(false)
          }
        }
      } else {
        result(FlutterError(code: "PERMISSION_DENIED", message: "Photos permission refusée", details: nil))
      }
    }
  }
}
