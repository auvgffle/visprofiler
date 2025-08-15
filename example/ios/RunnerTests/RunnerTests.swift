import Flutter
import UIKit
import XCTest

@testable import visprofiler

// Enhanced unit tests for iOS VisprofilerPlugin functionality
// Tests various platform-specific methods and iOS-specific limitations

class RunnerTests: XCTestCase {
  
  var plugin: VisprofilerPlugin!
  
  override func setUp() {
    super.setUp()
    plugin = VisprofilerPlugin()
  }
  
  override func tearDown() {
    plugin = nil
    super.tearDown()
  }

  func testGetPlatformVersion() {
    let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String, "iOS " + UIDevice.current.systemVersion)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  func testGetDeviceInfo() {
    let call = FlutterMethodCall(methodName: "getDeviceInfo", arguments: [])
    
    let resultExpectation = expectation(description: "device info result block must be called")
    plugin.handle(call) { result in
      guard let deviceInfo = result as? [String: Any] else {
        XCTFail("Device info should be a dictionary")
        return
      }
      
      // Test iOS-specific fields
      XCTAssertEqual(deviceInfo["brand"] as? String, "Apple")
      XCTAssertEqual(deviceInfo["manufacturer"] as? String, "Apple")
      XCTAssertEqual(deviceInfo["systemName"] as? String, UIDevice.current.systemName)
      XCTAssertNotNil(deviceInfo["systemVersion"])
      XCTAssertNotNil(deviceInfo["device"]) // Model identifier
      
      // Test that iOS doesn't have Android-specific fields
      XCTAssertNil(deviceInfo["androidId"])
      XCTAssertEqual(deviceInfo["isRooted"] as? Bool, false) // iOS concept
      
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 10)
  }
  
  func testGetNetworkInfo() {
    let call = FlutterMethodCall(methodName: "getNetworkInfo", arguments: [])
    
    let resultExpectation = expectation(description: "network info result block must be called")
    plugin.handle(call) { result in
      guard let networkInfo = result as? [String: Any] else {
        XCTFail("Network info should be a dictionary")
        return
      }
      
      // Test iOS network info structure
      XCTAssertNotNil(networkInfo["isConnected"])
      XCTAssertNotNil(networkInfo["networkType"])
      
      // Test iOS-specific limitations
      if let linkSpeed = networkInfo["linkSpeed"] as? Int {
        XCTAssertEqual(linkSpeed, -1, "iOS should return -1 for unavailable link speed")
      }
      
      if let macAddress = networkInfo["macAddress"] as? String {
        XCTAssertEqual(macAddress, "unavailable_ios", "iOS should indicate MAC address unavailability")
      }
      
      // Test that rxLinkSpeed and txLinkSpeed are -1 (not available on iOS)
      if let rxSpeed = networkInfo["rxLinkSpeed"] as? Int {
        XCTAssertEqual(rxSpeed, -1, "iOS should return -1 for rxLinkSpeed")
      }
      
      if let txSpeed = networkInfo["txLinkSpeed"] as? Int {
        XCTAssertEqual(txSpeed, -1, "iOS should return -1 for txLinkSpeed")
      }
      
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 10)
  }
  
  func testCheckLocationPermission() {
    let call = FlutterMethodCall(methodName: "checkLocationPermission", arguments: [])
    
    let resultExpectation = expectation(description: "location permission check result block must be called")
    plugin.handle(call) { result in
      guard let permissionInfo = result as? [String: Any] else {
        XCTFail("Location permission info should be a dictionary")
        return
      }
      
      // Test location permission structure
      XCTAssertNotNil(permissionInfo["status"])
      XCTAssertNotNil(permissionInfo["locationServicesEnabled"])
      XCTAssertNotNil(permissionInfo["hasWhenInUsePermission"])
      XCTAssertNotNil(permissionInfo["hasAlwaysPermission"])
      
      let status = permissionInfo["status"] as? String
      let validStatuses = ["granted_always", "granted_when_in_use", "denied", "not_determined", "restricted"]
      XCTAssertTrue(validStatuses.contains(status ?? ""), "Status should be one of the valid iOS permission statuses")
      
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 5)
  }
  
  func testGetPublicIp() {
    let call = FlutterMethodCall(methodName: "getPublicIp", arguments: [])
    
    let resultExpectation = expectation(description: "public IP result block must be called")
    plugin.handle(call) { result in
      // Result can be nil if no internet connection or services are down
      // Just verify that the method completes without crashing
      if let publicIp = result as? String {
        XCTAssertFalse(publicIp.isEmpty, "Public IP should not be empty if returned")
        // Basic IP format validation (IPv4)
        let ipComponents = publicIp.components(separatedBy: ".")
        if ipComponents.count == 4 {
          // Looks like IPv4
          for component in ipComponents {
            if let num = Int(component) {
              XCTAssertTrue(num >= 0 && num <= 255, "IPv4 component should be 0-255")
            }
          }
        }
      }
      
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 15) // Longer timeout for network call
  }
  
  func testMethodNotImplemented() {
    let call = FlutterMethodCall(methodName: "nonExistentMethod", arguments: [])
    
    let resultExpectation = expectation(description: "method not implemented should be called")
    plugin.handle(call) { result in
      if let error = result as? FlutterError {
        XCTAssertEqual(error.code, "FLUTT_METHOD_NOT_IMPLEMENTED")
      } else {
        // In iOS, FlutterMethodNotImplemented is represented differently
        // Just ensure we get a response indicating method not implemented
        XCTAssertNotNil(result)
      }
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
  
  // Test iOS-specific cellular info structure when available
  func testCellularInfoStructure() {
    let call = FlutterMethodCall(methodName: "getNetworkInfo", arguments: [])
    
    let resultExpectation = expectation(description: "cellular info structure test")
    plugin.handle(call) { result in
      guard let networkInfo = result as? [String: Any] else {
        XCTFail("Network info should be a dictionary")
        return
      }
      
      // If cellular is active, test iOS-specific fields
      if let hasCellular = networkInfo["hasCellular"] as? Bool, hasCellular {
        // Test iOS cellular structure
        XCTAssertNotNil(networkInfo["mobileCountryCode"])
        XCTAssertNotNil(networkInfo["mobileNetworkCode"])
        
        // Test that radioAccessTechnology is properly mapped
        if let rat = networkInfo["radioAccessTechnology"] as? String {
          XCTAssertFalse(rat.isEmpty, "Radio access technology should not be empty")
        }
        
        // Test iOS limitation for signal strength
        if let signalStrength = networkInfo["cellularSignalStrength"] as? Int {
          XCTAssertEqual(signalStrength, -1, "iOS should return -1 for cellular signal strength due to API limitations")
        }
      }
      
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 10)
  }
  
  // Test that iOS handles WiFi info appropriately
  func testWiFiInfoIosSpecific() {
    let call = FlutterMethodCall(methodName: "getNetworkInfo", arguments: [])
    
    let resultExpectation = expectation(description: "WiFi info iOS test")
    plugin.handle(call) { result in
      guard let networkInfo = result as? [String: Any] else {
        XCTFail("Network info should be a dictionary")
        return
      }
      
      // If WiFi is active, test iOS-specific behavior
      if let hasWifi = networkInfo["hasWifi"] as? Bool, hasWifi {
        // Test iOS WiFi limitations
        if let frequency = networkInfo["frequency"] as? Int {
          XCTAssertEqual(frequency, -1, "iOS should return -1 for WiFi frequency")
        }
        
        if let rssi = networkInfo["rssi"] as? Int {
          XCTAssertEqual(rssi, -1, "iOS should return -1 for RSSI due to limitations")
        }
        
        // SSID might be available or "Unknown" depending on permissions
        if let ssid = networkInfo["ssid"] as? String {
          XCTAssertFalse(ssid.isEmpty, "SSID should not be empty if returned")
        }
      }
      
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 10)
  }
}
