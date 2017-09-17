
import Foundation
import SimrunCore
import Commander

struct Config : Decodable {

  let devices: [String]

  private enum Key : CodingKey {
    case devices
  }

  init(from decoder: Decoder) throws {

    let c = try decoder.container(keyedBy: Key.self)
    self.devices = try c.decode([String].self, forKey: .devices)
  }
}

let g = Group {
  $0.command(
    "run",
    Argument("app path"),
    Argument("config path"),
    { (path: String, configPath: String) in

      do {
        let decoder = JSONDecoder()
        let data = try Data.init(contentsOf: URL.init(fileURLWithPath: configPath))
        let config = try decoder.decode(Config.self, from: data)

        let list = try Simctl.list()
        list.flattenDevices()
      } catch {

      }
  })
}

g.run()
