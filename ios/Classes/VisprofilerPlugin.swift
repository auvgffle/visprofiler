// import Flutter
// import UIKit
// import AdSupport
// import AppTrackingTransparency
// import CoreLocation
// import Network
// import CoreTelephony
// import SystemConfiguration
// import SystemConfiguration.CaptiveNetwork
// import Foundation

// #if canImport(NetworkExtension)
// import NetworkExtension
// #endif

// public class VisprofilerPlugin: NSObject, FlutterPlugin {
//   public static func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "visprofiler", binaryMessenger: registrar.messenger())
//     let instance = VisprofilerPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
//   }

//   public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     switch call.method {
//     case "getPlatformVersion":
//       result("iOS " + UIDevice.current.systemVersion)
//     case "getAdId":
//       getAdId(result: result)
//     case "getLocation":
//       getLocation(result: result)
//     case "getNetworkInfo":
//       getComprehensiveNetworkInfo(result: result)
//     case "getDeviceInfo":
//       getComprehensiveDeviceInfo(result: result)
//     case "getPublicIp":
//       getPublicIp(result: result)
//     case "requestLocationPermission":
//       requestLocationPermission(result: result)
//     case "checkLocationPermission":
//       checkLocationPermission(result: result)
//     default:
//       result(FlutterMethodNotImplemented)
//     }
//   }
  
//   private func getAdId(result: @escaping FlutterResult) {
//     if #available(iOS 14, *) {
//       ATTrackingManager.requestTrackingAuthorization { status in
//         DispatchQueue.main.async {
//           switch status {
//           case .authorized:
//             let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//             result(idfa != "00000000-0000-0000-0000-000000000000" ? idfa : nil)
//           default:
//             result(nil)
//           }
//         }
//       }
//     } else {
//       if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//         let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//         result(idfa != "00000000-0000-0000-0000-000000000000" ? idfa : nil)
//       } else {
//         result(nil)
//       }
//     }
//   }
  
//   private func getLocation(result: @escaping FlutterResult) {
//     let locationManager = CLLocationManager()
    
//     guard CLLocationManager.locationServicesEnabled() else {
//       result(nil)
//       return
//     }
    
//     let authorizationStatus: CLAuthorizationStatus
//     if #available(iOS 14.0, *) {
//       authorizationStatus = locationManager.authorizationStatus
//     } else {
//       authorizationStatus = CLLocationManager.authorizationStatus()
//     }
//     guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
//       result(nil)
//       return
//     }
    
//     if let location = locationManager.location {
//       let locationData: [String: Any] = [
//         "latitude": location.coordinate.latitude,
//         "longitude": location.coordinate.longitude,
//         "accuracy": location.horizontalAccuracy,
//         "altitude": location.altitude,
//         "speed": location.speed,
//         "bearing": location.course,
//         "provider": "CoreLocation"
//       ]
//       result(locationData)
//     } else {
//       result(nil)
//     }
//   }
  
//   private func getComprehensiveNetworkInfo(result: @escaping FlutterResult) {
//     DispatchQueue.global(qos: .background).async {
//       var networkInfo: [String: Any] = [:]
      
//       let monitor = NWPathMonitor()
//       let semaphore = DispatchSemaphore(value: 0)
      
//       monitor.pathUpdateHandler = { path in
//         networkInfo["isConnected"] = path.status == .satisfied
//         networkInfo["isExpensive"] = path.isExpensive
//         if #available(iOS 13.0, *) {
//           networkInfo["isConstrained"] = path.isConstrained
//         } else {
//           networkInfo["isConstrained"] = false
//         }
        
//         if path.usesInterfaceType(.wifi) {
//           networkInfo["hasWifi"] = true
//           networkInfo["hasCellular"] = false
//           networkInfo["networkType"] = "WiFi"
          
//           // Get WiFi info
//           if let wifiInfo = self.getWiFiInfo() {
//             networkInfo.merge(wifiInfo, uniquingKeysWith: { _, new in new })
//           }
          
//         } else if path.usesInterfaceType(.cellular) {
//           networkInfo["hasCellular"] = true
//           networkInfo["hasWifi"] = false
//           networkInfo["networkType"] = "Cellular"
          
//           // Get cellular info
//           if let cellularInfo = self.getCellularInfo() {
//             networkInfo.merge(cellularInfo, uniquingKeysWith: { _, new in new })
//           }
          
//         } else if path.usesInterfaceType(.wiredEthernet) {
//           networkInfo["networkType"] = "Ethernet"
//           networkInfo["hasWifi"] = false
//           networkInfo["hasCellular"] = false
//         } else {
//           networkInfo["networkType"] = "Unknown"
//           networkInfo["hasWifi"] = false
//           networkInfo["hasCellular"] = false
//         }
        
//         // VPN detection
//         networkInfo["hasVpn"] = path.usesInterfaceType(.other)
//         networkInfo["hasEthernet"] = path.usesInterfaceType(.wiredEthernet)
//         networkInfo["hasLowPan"] = false // iOS doesn't have LOWPAN
//         networkInfo["isValidated"] = path.status == .satisfied
//         networkInfo["isMetered"] = path.isExpensive
        
//         semaphore.signal()
//         monitor.cancel()
//       }
      
//       let queue = DispatchQueue(label: "NetworkMonitor")
//       monitor.start(queue: queue)
      
//       // Wait for network info with timeout
//       let timeout = DispatchTime.now() + .seconds(5)
//       _ = semaphore.wait(timeout: timeout)
      
//       DispatchQueue.main.async {
//         result(networkInfo)
//       }
//     }
//   }
  
//   private func getWiFiInfo() -> [String: Any]? {
//     var wifiInfo: [String: Any] = [:]
    
//     // Get WiFi SSID and BSSID (iOS 13+ requires location permission)
//     if let interfaces = CNCopySupportedInterfaces() as NSArray? {
//       for interface in interfaces {
//         if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
//           wifiInfo["ssid"] = interfaceInfo[kCNNetworkInfoKeySSID as String] ?? "Unknown"
//           wifiInfo["bssid"] = interfaceInfo[kCNNetworkInfoKeyBSSID as String] ?? "Unknown"
//           break
//         }
//       }
//     }
    
//     // Additional WiFi characteristics (limited on iOS)
//     wifiInfo["isWifiEnabled"] = true // If we're connected via WiFi, it's enabled
//     wifiInfo["linkSpeed"] = -1 // Not available on iOS
//     wifiInfo["frequency"] = -1 // Not available on iOS
//     wifiInfo["rssi"] = -1 // Not readily available on iOS
//     wifiInfo["signalLevel"] = -1 // Not readily available on iOS
//     wifiInfo["strength"] = -1 // Not readily available on iOS
//     wifiInfo["networkId"] = -1 // Not available on iOS
//     wifiInfo["macAddress"] = "unavailable_ios" // Not available since iOS 7
//     wifiInfo["rxLinkSpeed"] = -1 // Not available on iOS
//     wifiInfo["txLinkSpeed"] = -1 // Not available on iOS
    
//     return wifiInfo.isEmpty ? nil : wifiInfo
//   }
  
//   private func getCellularInfo() -> [String: Any]? {
//     var cellularInfo: [String: Any] = [:]
    
//     let networkInfo = CTTelephonyNetworkInfo()
    
//     // Carrier information
//     if #available(iOS 12.0, *) {
//       if let carriers = networkInfo.serviceSubscriberCellularProviders {
//         for (_, carrier) in carriers {
//           cellularInfo["networkOperatorName"] = carrier.carrierName ?? "Unknown"
//           cellularInfo["simOperatorName"] = carrier.carrierName ?? "Unknown"
//           cellularInfo["mobileCountryCode"] = carrier.mobileCountryCode ?? "Unknown"
//           cellularInfo["mobileNetworkCode"] = carrier.mobileNetworkCode ?? "Unknown"
//           cellularInfo["simCountryIso"] = carrier.isoCountryCode ?? "Unknown"
//           cellularInfo["isNetworkRoaming"] = false // Not directly available
//           break // Use first available carrier
//         }
//       }
//     } else {
//       if let carrier = networkInfo.subscriberCellularProvider {
//         cellularInfo["networkOperatorName"] = carrier.carrierName ?? "Unknown"
//         cellularInfo["simOperatorName"] = carrier.carrierName ?? "Unknown"
//         cellularInfo["mobileCountryCode"] = carrier.mobileCountryCode ?? "Unknown"
//         cellularInfo["mobileNetworkCode"] = carrier.mobileNetworkCode ?? "Unknown"
//         cellularInfo["simCountryIso"] = carrier.isoCountryCode ?? "Unknown"
//         cellularInfo["isNetworkRoaming"] = false // Not directly available
//       }
//     }
    
//     // Network technology
//     if #available(iOS 12.0, *) {
//       if let radioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
//         cellularInfo["radioAccessTechnology"] = radioAccessTechnology
//         cellularInfo["dataNetworkType"] = self.getNetworkTypeFromRAT(radioAccessTechnology)
//       }
//     } else {
//       if let radioAccessTechnology = networkInfo.currentRadioAccessTechnology {
//         cellularInfo["radioAccessTechnology"] = radioAccessTechnology
//         cellularInfo["dataNetworkType"] = self.getNetworkTypeFromRAT(radioAccessTechnology)
//       }
//     }
    
//     // Additional cellular info (limited on iOS)
//     cellularInfo["cellularSignalStrength"] = -1 // Not available without private APIs
//     cellularInfo["telephonyError"] = "iOS_limitations"
//     cellularInfo["networkOperator"] = "\(cellularInfo["mobileCountryCode"] ?? "")\(cellularInfo["mobileNetworkCode"] ?? "")"
    
//     // Set roaming status based on available information
//     cellularInfo["isNetworkRoaming"] = false // iOS doesn't provide direct roaming detection
    
//     return cellularInfo.isEmpty ? nil : cellularInfo
//   }
  
//   private func getNetworkTypeFromRAT(_ rat: String) -> String {
//     switch rat {
//     case CTRadioAccessTechnologyGPRS,
//          CTRadioAccessTechnologyEdge,
//          CTRadioAccessTechnologyCDMA1x:
//       return "2G"
//     case CTRadioAccessTechnologyWCDMA,
//          CTRadioAccessTechnologyHSDPA,
//          CTRadioAccessTechnologyHSUPA,
//          CTRadioAccessTechnologyCDMAEVDORev0,
//          CTRadioAccessTechnologyCDMAEVDORevA,
//          CTRadioAccessTechnologyCDMAEVDORevB,
//          CTRadioAccessTechnologyeHRPD:
//       return "3G"
//     case CTRadioAccessTechnologyLTE:
//       return "4G"
//     default:
//       if #available(iOS 14.1, *) {
//         if rat == CTRadioAccessTechnologyNRNSA || rat == CTRadioAccessTechnologyNR {
//           return "5G"
//         }
//       }
//       return "Unknown"
//     }
//   }
  
//   private func getComprehensiveDeviceInfo(result: @escaping FlutterResult) {
//     DispatchQueue.global(qos: .background).async {
//       var deviceInfo: [String: Any] = [:]
      
//       let device = UIDevice.current
      
//       // Basic device info
//       deviceInfo["brand"] = "Apple"
//       deviceInfo["manufacturer"] = "Apple"
//       deviceInfo["model"] = device.model
//       deviceInfo["systemName"] = device.systemName
//       deviceInfo["systemVersion"] = device.systemVersion
//       deviceInfo["device"] = self.getDeviceModelIdentifier()
//       deviceInfo["deviceName"] = device.name
//       deviceInfo["deviceType"] = self.getDeviceType()
      
//       // Device identifiers
//       deviceInfo["identifierForVendor"] = device.identifierForVendor?.uuidString
      
//       // App info
//       if let infoDictionary = Bundle.main.infoDictionary {
//         deviceInfo["packageName"] = Bundle.main.bundleIdentifier ?? "unknown"
//         deviceInfo["appVersion"] = infoDictionary["CFBundleShortVersionString"] as? String ?? "1.0.0"
//         deviceInfo["buildNumber"] = infoDictionary["CFBundleVersion"] as? String ?? "1"
//       }
      
//       // Memory info
//       let memoryInfo = self.getMemoryInfo()
//       deviceInfo.merge(memoryInfo, uniquingKeysWith: { _, new in new })
      
//       // Screen info
//       DispatchQueue.main.sync {
//         let screen = UIScreen.main
//         let bounds = screen.bounds
//         let scale = screen.scale
        
//         deviceInfo["screenWidth"] = Int(bounds.width * scale)
//         deviceInfo["screenHeight"] = Int(bounds.height * scale)
//         deviceInfo["screenDensity"] = Float(scale)
//         deviceInfo["densityDpi"] = Int(scale * 160) // Approximate conversion
        
//         // Screen size in inches (approximate)
//         let screenInches = self.getScreenSizeInches()
//         deviceInfo["screenInches"] = screenInches
//         deviceInfo["isTablet"] = device.userInterfaceIdiom == .pad
        
//         // Device characteristics
//         deviceInfo["hasNotch"] = self.hasNotch()
//         deviceInfo["hasDynamicIsland"] = self.hasDynamicIsland()
//       }
      
//       // Additional boolean fields with defaults
//       deviceInfo["isCharging"] = false // Placeholder - would need battery integration
//       deviceInfo["isJailbroken"] = false // Placeholder - would need jailbreak detection
//       deviceInfo["isRooted"] = false // iOS doesn't use rooted concept
      
//       // Additional info
//       deviceInfo["timezone"] = TimeZone.current.identifier
//       deviceInfo["fingerprint"] = "iOS_\(device.systemVersion)_\(self.getDeviceModelIdentifier())"
      
//       DispatchQueue.main.async {
//         result(deviceInfo)
//       }
//     }
//   }
  
//   private func getDeviceModelIdentifier() -> String {
//     var systemInfo = utsname()
//     uname(&systemInfo)
//     let machineMirror = Mirror(reflecting: systemInfo.machine)
//     let identifier = machineMirror.children.reduce("") { identifier, element in
//       guard let value = element.value as? Int8, value != 0 else { return identifier }
//       return identifier + String(UnicodeScalar(UInt8(value))!)
//     }
//     return identifier
//   }
  
//   private func getDeviceType() -> String {
//     let device = UIDevice.current
//     if device.userInterfaceIdiom == .pad {
//       return "Tablet"
//     } else if device.userInterfaceIdiom == .phone {
//       return "Handset"
//     } else {
//       return "Unknown"
//     }
//   }
  
//   private func getMemoryInfo() -> [String: Any] {
//     var memoryInfo: [String: Any] = [:]
    
//     // Physical memory
//     let physicalMemory = ProcessInfo.processInfo.physicalMemory
//     memoryInfo["totalMemory"] = physicalMemory
    
//     // Available memory (approximate)
//     var info = mach_task_basic_info()
//     var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
//     let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
//       $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//         task_info(mach_task_self_,
//                  task_flavor_t(MACH_TASK_BASIC_INFO),
//                  $0,
//                  &count)
//       }
//     }
    
//     if kerr == KERN_SUCCESS {
//       memoryInfo["usedMemory"] = info.resident_size
//       memoryInfo["availableMemory"] = physicalMemory - UInt64(info.resident_size)
//     } else {
//       memoryInfo["memoryError"] = "Failed to get memory info"
//     }
    
//     return memoryInfo
//   }
  
//   private func getScreenSizeInches() -> Double {
//     let modelIdentifier = getDeviceModelIdentifier()
    
//     // This is a simplified mapping - in practice, you'd have a comprehensive list
//     if modelIdentifier.contains("iPhone") {
//       if modelIdentifier.contains("14,7") || modelIdentifier.contains("14,8") { // iPhone 14 Plus, Pro Max
//         return 6.7
//       } else if modelIdentifier.contains("14,") { // iPhone 14 series
//         return 6.1
//       } else if modelIdentifier.contains("13,") { // iPhone 12/13 series
//         return 6.1
//       }
//       return 6.1 // Default for modern iPhones
//     } else if modelIdentifier.contains("iPad") {
//       if modelIdentifier.contains("Pro") {
//         return modelIdentifier.contains("12.9") ? 12.9 : 11.0
//       }
//       return 10.9 // Default for modern iPads
//     }
//     return 0.0
//   }
  
//   private func hasNotch() -> Bool {
//     if #available(iOS 11.0, *) {
//       return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
//     }
//     return false
//   }
  
//   private func hasDynamicIsland() -> Bool {
//     // Dynamic Island detection (iPhone 14 Pro models and later)
//     let modelIdentifier = getDeviceModelIdentifier()
//     return modelIdentifier.contains("iPhone15,2") || modelIdentifier.contains("iPhone15,3") // iPhone 14 Pro, Pro Max
//   }
  
//   private func getPublicIp(result: @escaping FlutterResult) {
//     DispatchQueue.global(qos: .background).async {
//       let services = [
//         "https://api.ipify.org",
//         "https://httpbin.org/ip",
//         "https://icanhazip.com",
//         "https://ifconfig.me/ip"
//       ]
      
//       for service in services {
//         if let url = URL(string: service) {
//           var request = URLRequest(url: url)
//           request.timeoutInterval = 10.0
//           request.setValue("VisProfiler-iOS", forHTTPHeaderField: "User-Agent")
          
//           let semaphore = DispatchSemaphore(value: 0)
//           var publicIp: String? = nil
          
//           let task = URLSession.shared.dataTask(with: request) { data, response, error in
//             defer { semaphore.signal() }
            
//             guard let data = data,
//                   let httpResponse = response as? HTTPURLResponse,
//                   httpResponse.statusCode == 200,
//                   error == nil else {
//               return
//             }
            
//             let responseString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            
//             if service.contains("httpbin") {
//               // Parse JSON response
//               if let jsonData = responseString?.data(using: .utf8),
//                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
//                  let origin = json["origin"] as? String {
//                 publicIp = origin
//               }
//             } else {
//               publicIp = responseString
//             }
//           }
          
//           task.resume()
//           _ = semaphore.wait(timeout: .now() + 10.0)
          
//           if let ip = publicIp {
//             DispatchQueue.main.async {
//               result(ip)
//             }
//             return
//           }
//         }
//       }
      
//       // All services failed
//       DispatchQueue.main.async {
//         result(nil)
//       }
//     }
//   }
  
//   private func checkLocationPermission(result: @escaping FlutterResult) {
//     let locationManager = CLLocationManager()
//     let status: CLAuthorizationStatus
//     if #available(iOS 14.0, *) {
//       status = locationManager.authorizationStatus
//     } else {
//       status = CLLocationManager.authorizationStatus()
//     }
    
//     var statusString: String
//     switch status {
//     case .authorizedAlways:
//       statusString = "granted_always"
//     case .authorizedWhenInUse:
//       statusString = "granted_when_in_use"
//     case .denied:
//       statusString = "denied"
//     case .notDetermined:
//       statusString = "not_determined"
//     case .restricted:
//       statusString = "restricted"
//     @unknown default:
//       statusString = "unknown"
//     }
    
//     let permissionInfo: [String: Any] = [
//       "status": statusString,
//       "hasAlwaysPermission": status == .authorizedAlways,
//       "hasWhenInUsePermission": status == .authorizedWhenInUse || status == .authorizedAlways,
//       "locationServicesEnabled": CLLocationManager.locationServicesEnabled()
//     ]
    
//     result(permissionInfo)
//   }
  
//   private func requestLocationPermission(result: @escaping FlutterResult) {
//     let locationManager = CLLocationManager()
    
//     // Check current status
//     let status: CLAuthorizationStatus
//     if #available(iOS 14.0, *) {
//       status = locationManager.authorizationStatus
//     } else {
//       status = CLLocationManager.authorizationStatus()
//     }
    
//     switch status {
//     case .notDetermined:
//       // Request permission for the first time
//       locationManager.requestWhenInUseAuthorization()
//       // Return current status after request
//       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//         self.checkLocationPermission(result: result)
//       }
//     case .denied, .restricted:
//       // Permission denied or restricted
//       let permissionInfo: [String: Any] = [
//         "status": "denied",
//         "hasAlwaysPermission": false,
//         "hasWhenInUsePermission": false,
//         "locationServicesEnabled": CLLocationManager.locationServicesEnabled(),
//         "canRequestPermission": false,
//         "message": "Location permission denied. Please enable in Settings."
//       ]
//       result(permissionInfo)
//     case .authorizedWhenInUse, .authorizedAlways:
//       // Already authorized
//       checkLocationPermission(result: result)
//     @unknown default:
//       checkLocationPermission(result: result)
//     }
//   }
// }










import Flutter
import UIKit
import AdSupport
import AppTrackingTransparency
import CoreLocation
import Network
import CoreTelephony
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import Foundation

#if canImport(NetworkExtension)
import NetworkExtension
#endif

public class VisprofilerPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationPermissionResult: FlutterResult?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "visprofiler", binaryMessenger: registrar.messenger())
    let instance = VisprofilerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getAdId":
      getAdId(result: result)
    case "getLocation":
      getLocation(result: result)
    case "getNetworkInfo":
      getComprehensiveNetworkInfo(result: result)
    case "getDeviceInfo":
      getComprehensiveDeviceInfo(result: result)
    case "getPublicIp":
      getPublicIp(result: result)
    case "requestLocationPermission":
      requestLocationPermission(result: result)
    case "checkLocationPermission":
      checkLocationPermission(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Advertising ID

  private func getAdId(result: @escaping FlutterResult) {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { status in
        DispatchQueue.main.async {
          switch status {
          case .authorized:
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            result(idfa != "00000000-0000-0000-0000-000000000000" ? idfa : nil)
          default:
            result(nil)
          }
        }
      }
    } else {
      if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        result(idfa != "00000000-0000-0000-0000-000000000000" ? idfa : nil)
      } else {
        result(nil)
      }
    }
  }

  // MARK: - Location

  private func getLocation(result: @escaping FlutterResult) {
    print("[VisprofilerPlugin] getLocation called")
    DispatchQueue.main.async {
      guard CLLocationManager.locationServicesEnabled() else {
        print("[VisprofilerPlugin] Location services disabled system-wide")
        result(nil)
        return
      }
      
      print("[VisprofilerPlugin] Location services enabled")
      self.locationManager = CLLocationManager()
      self.locationManager?.delegate = self
      self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
      self.locationPermissionResult = result // Store result for callback
      
      let status: CLAuthorizationStatus
      if #available(iOS 14.0, *) {
        status = self.locationManager!.authorizationStatus
      } else {
        status = CLLocationManager.authorizationStatus()
      }
      
      print("[VisprofilerPlugin] Current location authorization status: \(status.rawValue)")
      
      switch status {
      case .notDetermined:
        print("[VisprofilerPlugin] Requesting location permission for getLocation")
        self.locationManager?.requestWhenInUseAuthorization()
      case .authorizedWhenInUse, .authorizedAlways:
        print("[VisprofilerPlugin] Location already authorized, requesting location")
        self.locationManager?.requestLocation()
      case .denied, .restricted:
        print("[VisprofilerPlugin] Location permission denied/restricted")
        result(nil)
        self.cleanupLocationManager()
        return
      @unknown default:
        print("[VisprofilerPlugin] Unknown location permission status")
        result(nil)
        self.cleanupLocationManager()
        return
      }
      
      // Timeout after 10 seconds
      DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        if self.locationPermissionResult != nil {
          print("[VisprofilerPlugin] Location request timed out")
          self.locationPermissionResult?(nil)
          self.cleanupLocationManager()
        }
      }
    }
  }

  // MARK: - Network Info

  private func getComprehensiveNetworkInfo(result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .background).async {
      var networkInfo: [String: Any] = [:]

      let monitor = NWPathMonitor()
      let semaphore = DispatchSemaphore(value: 1) // FIX: initial 1 avoids potential deadlocks if handler fires immediately
      semaphore.wait()

      monitor.pathUpdateHandler = { path in
        networkInfo["isConnected"] = path.status == .satisfied
        networkInfo["isExpensive"] = path.isExpensive
        if #available(iOS 13.0, *) {
          networkInfo["isConstrained"] = path.isConstrained
        } else {
          networkInfo["isConstrained"] = false
        }

        if path.usesInterfaceType(.wifi) {
          networkInfo["hasWifi"] = true
          networkInfo["hasCellular"] = false
          networkInfo["networkType"] = "WiFi"

          if let wifiInfo = self.getWiFiInfo() {
            networkInfo.merge(wifiInfo, uniquingKeysWith: { _, new in new })
          }

        } else if path.usesInterfaceType(.cellular) {
          networkInfo["hasCellular"] = true
          networkInfo["hasWifi"] = false
          networkInfo["networkType"] = "Cellular"

          if let cellularInfo = self.getCellularInfo() {
            networkInfo.merge(cellularInfo, uniquingKeysWith: { _, new in new })
          }

        } else if path.usesInterfaceType(.wiredEthernet) {
          networkInfo["networkType"] = "Ethernet"
          networkInfo["hasWifi"] = false
          networkInfo["hasCellular"] = false
        } else {
          networkInfo["networkType"] = "Unknown"
          networkInfo["hasWifi"] = false
          networkInfo["hasCellular"] = false
        }

        // Keep existing flags
        networkInfo["hasVpn"] = path.usesInterfaceType(.other)
        networkInfo["hasEthernet"] = path.usesInterfaceType(.wiredEthernet)
        networkInfo["hasLowPan"] = false
        networkInfo["isValidated"] = path.status == .satisfied
        networkInfo["isMetered"] = path.isExpensive

        semaphore.signal()
        monitor.cancel()
      }

      let queue = DispatchQueue(label: "NetworkMonitor")
      monitor.start(queue: queue)

      // Wait up to 5s
      _ = semaphore.wait(timeout: .now() + .seconds(5))

      DispatchQueue.main.async {
        result(networkInfo)
      }
    }
  }

  private func getWiFiInfo() -> [String: Any]? {
    var wifiInfo: [String: Any] = [:]

    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
      for interface in interfaces {
        if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
          wifiInfo["ssid"] = interfaceInfo[kCNNetworkInfoKeySSID as String] ?? "Unknown"
          wifiInfo["bssid"] = interfaceInfo[kCNNetworkInfoKeyBSSID as String] ?? "Unknown"
          break
        }
      }
    }

    wifiInfo["isWifiEnabled"] = true
    wifiInfo["linkSpeed"] = -1
    wifiInfo["frequency"] = -1
    wifiInfo["rssi"] = -1
    wifiInfo["signalLevel"] = -1
    wifiInfo["strength"] = -1
    wifiInfo["networkId"] = -1
    wifiInfo["macAddress"] = "unavailable_ios"
    wifiInfo["rxLinkSpeed"] = -1
    wifiInfo["txLinkSpeed"] = -1

    return wifiInfo.isEmpty ? nil : wifiInfo
  }

  private func getCellularInfo() -> [String: Any]? {
    var cellularInfo: [String: Any] = [:]
    let networkInfo = CTTelephonyNetworkInfo()

    // Carrier
    if #available(iOS 12.0, *) {
      if let carriers = networkInfo.serviceSubscriberCellularProviders {
        for (_, carrier) in carriers {
          cellularInfo["networkOperatorName"] = carrier.carrierName ?? "Unknown"
          cellularInfo["simOperatorName"] = carrier.carrierName ?? "Unknown"
          cellularInfo["mobileCountryCode"] = carrier.mobileCountryCode ?? "Unknown"
          cellularInfo["mobileNetworkCode"] = carrier.mobileNetworkCode ?? "Unknown"
          cellularInfo["simCountryIso"] = carrier.isoCountryCode ?? "Unknown"
          cellularInfo["isNetworkRoaming"] = false
          break
        }
      }
    } else if let carrier = networkInfo.subscriberCellularProvider {
      cellularInfo["networkOperatorName"] = carrier.carrierName ?? "Unknown"
      cellularInfo["simOperatorName"] = carrier.carrierName ?? "Unknown"
      cellularInfo["mobileCountryCode"] = carrier.mobileCountryCode ?? "Unknown"
      cellularInfo["mobileNetworkCode"] = carrier.mobileNetworkCode ?? "Unknown"
      cellularInfo["simCountryIso"] = carrier.isoCountryCode ?? "Unknown"
      cellularInfo["isNetworkRoaming"] = false
    }

    // RAT
    if #available(iOS 12.0, *) {
      if let rat = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
        cellularInfo["radioAccessTechnology"] = rat
        cellularInfo["dataNetworkType"] = self.getNetworkTypeFromRAT(rat)
      }
    } else if let rat = networkInfo.currentRadioAccessTechnology {
      cellularInfo["radioAccessTechnology"] = rat
      cellularInfo["dataNetworkType"] = self.getNetworkTypeFromRAT(rat)
    }

    cellularInfo["cellularSignalStrength"] = -1
    cellularInfo["telephonyError"] = "iOS_limitations"
    cellularInfo["networkOperator"] = "\(cellularInfo["mobileCountryCode"] ?? "")\(cellularInfo["mobileNetworkCode"] ?? "")"
    cellularInfo["isNetworkRoaming"] = false

    return cellularInfo.isEmpty ? nil : cellularInfo
  }

  private func getNetworkTypeFromRAT(_ rat: String) -> String {
    switch rat {
    case CTRadioAccessTechnologyGPRS,
         CTRadioAccessTechnologyEdge,
         CTRadioAccessTechnologyCDMA1x:
      return "2G"
    case CTRadioAccessTechnologyWCDMA,
         CTRadioAccessTechnologyHSDPA,
         CTRadioAccessTechnologyHSUPA,
         CTRadioAccessTechnologyCDMAEVDORev0,
         CTRadioAccessTechnologyCDMAEVDORevA,
         CTRadioAccessTechnologyCDMAEVDORevB,
         CTRadioAccessTechnologyeHRPD:
      return "3G"
    case CTRadioAccessTechnologyLTE:
      return "4G"
    default:
      if #available(iOS 14.1, *) {
        if rat == CTRadioAccessTechnologyNRNSA || rat == CTRadioAccessTechnologyNR {
          return "5G"
        }
      }
      return "Unknown"
    }
  }

  // MARK: - Device Info

  private func getComprehensiveDeviceInfo(result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .background).async {
      var deviceInfo: [String: Any] = [:]
      let device = UIDevice.current

      deviceInfo["brand"] = "Apple"
      deviceInfo["manufacturer"] = "Apple"
      deviceInfo["model"] = device.model
      deviceInfo["systemName"] = device.systemName
      deviceInfo["systemVersion"] = device.systemVersion
      deviceInfo["device"] = self.getDeviceModelIdentifier() // FIX: now safe
      deviceInfo["deviceName"] = device.name
      deviceInfo["deviceType"] = self.getDeviceType()

      deviceInfo["identifierForVendor"] = device.identifierForVendor?.uuidString

      if let infoDictionary = Bundle.main.infoDictionary {
        deviceInfo["packageName"] = Bundle.main.bundleIdentifier ?? "unknown"
        deviceInfo["appVersion"] = infoDictionary["CFBundleShortVersionString"] as? String ?? "1.0.0"
        deviceInfo["buildNumber"] = infoDictionary["CFBundleVersion"] as? String ?? "1"
      }

      // Memory
      let memoryInfo = self.getMemoryInfo()
      deviceInfo.merge(memoryInfo, uniquingKeysWith: { _, new in new })

      // Screen (main thread)
      DispatchQueue.main.sync {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale

        deviceInfo["screenWidth"] = Int(bounds.width * scale)
        deviceInfo["screenHeight"] = Int(bounds.height * scale)
        deviceInfo["screenDensity"] = Float(scale)
        deviceInfo["densityDpi"] = Int(scale * 160)

        let screenInches = self.getScreenSizeInches()
        deviceInfo["screenInches"] = screenInches
        deviceInfo["isTablet"] = device.userInterfaceIdiom == .pad

        deviceInfo["hasNotch"] = self.hasNotch()
        deviceInfo["hasDynamicIsland"] = self.hasDynamicIsland()
      }

      deviceInfo["isCharging"] = false
      deviceInfo["isJailbroken"] = false
      deviceInfo["isRooted"] = false

      deviceInfo["timezone"] = TimeZone.current.identifier
      deviceInfo["fingerprint"] = "iOS_\(device.systemVersion)_\(self.getDeviceModelIdentifier())"

      DispatchQueue.main.async {
        result(deviceInfo)
      }
    }
  }

  // FIX: Crash-free, simple model identifier with sysctl → uname fallback
  private func getDeviceModelIdentifier(default defaultValue: String = "unknown") -> String {
    // Prefer sysctl hw.machine
    var size: Int = 0
    if sysctlbyname("hw.machine", nil, &size, nil, 0) == 0, size > 0 {
      var machine = [CChar](repeating: 0, count: size)
      if sysctlbyname("hw.machine", &machine, &size, nil, 0) == 0 {
        let id = String(cString: machine).trimmingCharacters(in: .whitespacesAndNewlines)
        if !id.isEmpty { return id }
      }
    }
    // Fallback to uname
    var systemInfo = utsname()
    uname(&systemInfo)
    let unameId = withUnsafePointer(to: &systemInfo.machine) { ptr in
      ptr.withMemoryRebound(to: CChar.self, capacity: 1) {
        String(cString: $0)
      }
    }.trimmingCharacters(in: .whitespacesAndNewlines)
    return unameId.isEmpty ? defaultValue : unameId
  }

  // NOTE: Kept signature used elsewhere
  private func getDeviceModelIdentifier() -> String {
    return getDeviceModelIdentifier(default: "unknown")
  }

  private func getDeviceType() -> String {
    let device = UIDevice.current
    if device.userInterfaceIdiom == .pad {
      return "Tablet"
    } else if device.userInterfaceIdiom == .phone {
      return "Handset"
    } else {
      return "Unknown"
    }
  }

  private func getMemoryInfo() -> [String: Any] {
    var memoryInfo: [String: Any] = [:]

    let physicalMemory = ProcessInfo.processInfo.physicalMemory
    memoryInfo["totalMemory"] = physicalMemory

    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self_,
                  task_flavor_t(MACH_TASK_BASIC_INFO),
                  $0,
                  &count)
      }
    }

    if kerr == KERN_SUCCESS {
      memoryInfo["usedMemory"] = info.resident_size
      memoryInfo["availableMemory"] = physicalMemory - UInt64(info.resident_size)
    } else {
      memoryInfo["memoryError"] = "Failed to get memory info"
    }

    return memoryInfo
  }

  private func getScreenSizeInches() -> Double {
    let modelIdentifier = getDeviceModelIdentifier()

    // Preserve your simple mapping
    if modelIdentifier.contains("iPhone") {
      if modelIdentifier.contains("14,7") || modelIdentifier.contains("14,8") { // iPhone 14 Plus/Pro Max
        return 6.7
      } else if modelIdentifier.contains("14,") { // iPhone 14 series
        return 6.1
      } else if modelIdentifier.contains("13,") { // iPhone 12/13 series
        return 6.1
      }
      return 6.1
    } else if modelIdentifier.contains("iPad") {
      if modelIdentifier.contains("Pro") {
        return modelIdentifier.contains("12.9") ? 12.9 : 11.0
      }
      return 10.9
    }
    return 0.0
  }

  private func hasNotch() -> Bool {
    if #available(iOS 11.0, *) {
      // FIX: Safer access to a window across iOS versions
      let topInset: CGFloat
      if #available(iOS 13.0, *) {
        let window = UIApplication.shared.connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .flatMap { $0.windows }
          .first { $0.isKeyWindow }
        topInset = window?.safeAreaInsets.top ?? 0
      } else {
        topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
      }
      return topInset > 20
    }
    return false
  }

  private func hasDynamicIsland() -> Bool {
    // Keep your existing simple check
    let modelIdentifier = getDeviceModelIdentifier()
    return modelIdentifier.contains("iPhone15,2") || modelIdentifier.contains("iPhone15,3")
  }

  // MARK: - Public IP

  private func getPublicIp(result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .background).async {
      let services = [
        "https://api.ipify.org",
        "https://httpbin.org/ip",
        "https://icanhazip.com",
        "https://ifconfig.me/ip"
      ]

      for service in services {
        guard let url = URL(string: service) else { continue }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.setValue("VisProfiler-iOS", forHTTPHeaderField: "User-Agent")

        let semaphore = DispatchSemaphore(value: 0)
        var publicIp: String?

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          defer { semaphore.signal() }

          guard let data = data,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                error == nil else {
            return
          }

          let responseString = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

          if service.contains("httpbin"),
             let jsonData = responseString?.data(using: .utf8),
             let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
             let origin = json["origin"] as? String {
            publicIp = origin
          } else {
            publicIp = responseString
          }
        }

        task.resume()
        _ = semaphore.wait(timeout: .now() + 10.0)

        if let ip = publicIp, !ip.isEmpty {
          DispatchQueue.main.async { result(ip) }
          return
        }
      }

      DispatchQueue.main.async { result(nil) }
    }
  }

  // MARK: - Location Permissions

  private func checkLocationPermission(result: @escaping FlutterResult) {
    let locationManager = CLLocationManager()
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = locationManager.authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }

    let statusString: String
    switch status {
    case .authorizedAlways:
      statusString = "granted_always"
    case .authorizedWhenInUse:
      statusString = "granted_when_in_use"
    case .denied:
      statusString = "denied"
    case .notDetermined:
      statusString = "not_determined"
    case .restricted:
      statusString = "restricted"
    @unknown default:
      statusString = "unknown"
    }

    let permissionInfo: [String: Any] = [
      "status": statusString,
      "hasAlwaysPermission": status == .authorizedAlways,
      "hasWhenInUsePermission": status == .authorizedWhenInUse || status == .authorizedAlways,
      "locationServicesEnabled": CLLocationManager.locationServicesEnabled()
    ]

    result(permissionInfo)
  }

  private func requestLocationPermission(result: @escaping FlutterResult) {
    print("[VisprofilerPlugin] requestLocationPermission called")
    
    // Ensure we're on the main thread
    DispatchQueue.main.async {
      // Initialize location manager if not already done
      if self.locationManager == nil {
        print("[VisprofilerPlugin] Initializing location manager")
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
      }
      
      guard let manager = self.locationManager else {
        print("[VisprofilerPlugin] Failed to initialize location manager")
        result(["status": "error", "message": "Failed to initialize location manager"])
        return
      }

      let status: CLAuthorizationStatus
      if #available(iOS 14.0, *) {
        status = manager.authorizationStatus
      } else {
        status = CLLocationManager.authorizationStatus()
      }
      
      print("[VisprofilerPlugin] Current location status: \(status.rawValue)")

      switch status {
      case .notDetermined:
        print("[VisprofilerPlugin] Status is notDetermined, requesting permission...")
        // Store result to call later in delegate
        self.locationPermissionResult = result
        manager.requestWhenInUseAuthorization()
        print("[VisprofilerPlugin] Permission request sent")
      case .denied, .restricted:
        print("[VisprofilerPlugin] Permission denied or restricted")
        let permissionInfo: [String: Any] = [
          "status": "denied",
          "hasAlwaysPermission": false,
          "hasWhenInUsePermission": false,
          "locationServicesEnabled": CLLocationManager.locationServicesEnabled(),
          "canRequestPermission": false,
          "message": "Location permission denied. Please enable in Settings."
        ]
        result(permissionInfo)
      case .authorizedWhenInUse, .authorizedAlways:
        print("[VisprofilerPlugin] Already authorized")
        self.checkLocationPermission(result: result)
      @unknown default:
        print("[VisprofilerPlugin] Unknown status")
        self.checkLocationPermission(result: result)
      }
    }
  }
  
  // MARK: - CLLocationManagerDelegate
  
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("[VisprofilerPlugin] locationManager:didChangeAuthorization called with status: \(status.rawValue)")
    
    let statusString: String
    switch status {
    case .authorizedAlways:
      statusString = "granted_always"
    case .authorizedWhenInUse:
      statusString = "granted_when_in_use"
    case .denied:
      statusString = "denied"
    case .notDetermined:
      statusString = "not_determined"
    case .restricted:
      statusString = "restricted"
    @unknown default:
      statusString = "unknown"
    }
    
    print("[VisprofilerPlugin] Status changed to: \(statusString)")
    
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      print("[VisprofilerPlugin] Location authorized in delegate, requesting location")
      self.locationManager?.requestLocation()
    case .denied, .restricted:
      print("[VisprofilerPlugin] Location permission denied in delegate")
      self.locationPermissionResult?(nil)
      self.cleanupLocationManager()
    case .notDetermined:
      print("[VisprofilerPlugin] Location permission still not determined in delegate")
      // Still waiting for user decision
      break
    @unknown default:
      print("[VisprofilerPlugin] Unknown location permission status in delegate")
      self.locationPermissionResult?(nil)
      self.cleanupLocationManager()
    }
    
    // Call the stored result if we have one (from permission request)
    if let result = locationPermissionResult, (status == .denied || status == .restricted) {
      print("[VisprofilerPlugin] Calling stored result with new permission status")
      locationPermissionResult = nil
      checkLocationPermission(result: result)
    }
  }
  
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("[VisprofilerPlugin] Location updated: \(locations.count) locations")
    guard let location = locations.last else {
      print("[VisprofilerPlugin] No location in update")
      self.locationPermissionResult?(nil)
      self.cleanupLocationManager()
      return
    }
    
    print("[VisprofilerPlugin] Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    let locationData: [String: Any] = [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude,
      "accuracy": location.horizontalAccuracy,
      "altitude": location.altitude,
      "speed": location.speed >= 0 ? location.speed : 0,
      "bearing": location.course >= 0 ? location.course : 0,
      "provider": "CoreLocation",
      "timestamp": location.timestamp.timeIntervalSince1970 * 1000
    ]
    
    self.locationPermissionResult?(locationData)
    self.cleanupLocationManager()
  }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("[VisprofilerPlugin] locationManager:didFailWithError: \(error.localizedDescription)")
    self.locationPermissionResult?(nil)
    self.cleanupLocationManager()
  }
  
  private func cleanupLocationManager() {
    print("[VisprofilerPlugin] Cleaning up location manager")
    self.locationManager?.stopUpdatingLocation()
    self.locationManager = nil
    self.locationPermissionResult = nil
  }
}
