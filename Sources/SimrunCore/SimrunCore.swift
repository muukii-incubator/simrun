//
//  SimrunCore.swift
//  simrun
//
//  Created by muukii on 9/17/17.
//

import Foundation

import ShellOut

public enum Simctl {

  public static func openSimulator() throws {
    try shellOut(to: "open $(xcode-select -p)/Applications/Simulator.app")
  }

  public static func list() throws -> ListResult {
    let r = try shellOut(to: "xcrun simctl list --json")
    let decoder = JSONDecoder()
    let d = r.data(using: .utf8)!
    let result = try decoder.decode(ListResult.self, from: d)
    return result
  }

  public static func boot(device: Device) throws {
    try shellOut(to: "xcrun simctl boot \(device.udid)")
  }

  public static func install(appPath path: String, device: Device) throws {
    try shellOut(to: "xcrun simctl install \(path) \(device.udid)")
  }

  public static func install(appPath path: String, devices: [Device]) throws {
    try devices.forEach {
      try install(appPath: path, device: $0)
    }
  }

  public static func launch(device: Device, appIdentifier: String) throws {
    try shellOut(to: "xcrun simctl lanuch \(device.udid) \(appIdentifier)")
  }

  public static func launch(devices: [Device], appIdentifier: String) throws {
    try devices.forEach {
      try launch(device: $0, appIdentifier: appIdentifier)
    }
  }

  public static func create(name: String, device: Device, runtime: Runtime) throws {
    try shellOut(to: "xcrun simctl create \(name) \(device.udid) \(runtime.identifier)")
  }
}

public struct Device : Decodable {

  public enum State : Decodable {
    case booted
    case shutdown

    public init(from decoder: Decoder) throws {
      let c = try decoder.singleValueContainer()
      if try c.decode(String.self) == "(Shutdown)" {
        self = .shutdown
      } else {
        self = .booted
      }
    }
  }

  public let state: State
  public let availability: Bool
  public let name: String
  public let udid: String

  private enum Key : CodingKey {
    case availability
    case state
    case name
    case udid
  }

  public init(from decoder: Decoder) throws {

    let c = try decoder.container(keyedBy: Key.self)

    self.state = try c.decode(State.self, forKey: .state)
    self.name = try c.decode(String.self, forKey: .name)
    self.udid = try c.decode(String.self, forKey: .udid)

    let _availability = try c.decode(String.self, forKey: .availability)
    if _availability == "(available)" {
      self.availability = true
    } else {
      self.availability = false
    }
  }
}

public struct DeviceType : Decodable {

  public let name: String
  public let identifier: String
}

public struct Runtime : Decodable {

  public let buildversion: String
  public let name: String
  public let identifier: String
  public let version: String
  public let availability: Bool

  private enum Key : CodingKey {
    case buildversion
    case availability
    case name
    case identifier
    case version
  }

  public init(from decoder: Decoder) throws {

    let c = try decoder.container(keyedBy: Key.self)

    self.buildversion = try c.decode(String.self, forKey: .buildversion)
    self.name = try c.decode(String.self, forKey: .name)
    self.identifier = try c.decode(String.self, forKey: .identifier)
    self.version = try c.decode(String.self, forKey: .version)

    let _availability = try c.decode(String.self, forKey: .availability)
    if _availability == "(available)" {
      self.availability = true
    } else {
      self.availability = false
    }
  }
}

public struct ListResult : Decodable {

  private enum Key : String, CodingKey {
    case deviceTypes = "devicetypes"
    case devices
    case runtimes
  }

  public let deviceTypes: [DeviceType]
  public let devices: [String : [Device]]
  public let runtimes: [Runtime]

  public init(from decoder: Decoder) throws {

    let c = try decoder.container(keyedBy: Key.self)
    deviceTypes = try c.decode([DeviceType].self, forKey: .deviceTypes)
    devices = try c.decode([String : [Device]].self, forKey: .devices)
    runtimes = try c.decode([Runtime].self, forKey: .runtimes)
  }

  public func flattenDevices() -> [Device] {
    return devices.flatMap { $0.value }
  }
}
