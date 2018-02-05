import Foundation
import AppKit

class WorkspaceDelegate {
  let streams: [GenericStream]
  init(streams: [GenericStream]) {
    self.streams = streams
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(run_streams), name: NSWorkspace.didWakeNotification, object: nil)
  }
  
  @objc func run_streams() {
    for stream in streams {
      stream.run()
    }
  }
}
