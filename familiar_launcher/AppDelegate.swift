/**
 Familiar Launcher: a helper to launch Familiar at macOS login.
 Copyright (C) 2018 Skyleaf Design
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */



import Cocoa

extension Notification.Name {
  static let close_launcher = Notification.Name("close_launcher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @objc func terminate() {
    print("Terminate application")
    NSApp.terminate(nil)
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let main_app_id = "com.skyleafdesign.familiar"
    let apps = NSWorkspace.shared.runningApplications
    let main_is_running = apps.filter({ $0.bundleIdentifier == main_app_id }).count > 0
    
    // If the launcher is already running, exit.
    guard !main_is_running else { self.terminate(); return }

    // Listen for when the main application tells us to close.
    DistributedNotificationCenter.default().addObserver(
      self,
      selector: #selector(self.terminate),
      name: .close_launcher,
      object: main_app_id
    )
    
    // Get our current path, and navigate up and over, to get the parent app that we are
    // emebbed inside.
    let path = Bundle.main.bundlePath as NSString
    var components = path.pathComponents
    components.removeLast(3)
    components.append("MacOS")
    components.append("familiar")
    
    let main_app_path = NSString.path(withComponents: components)
    
    // Launch familiar
    NSWorkspace.shared.launchApplication(main_app_path)
  }
}

