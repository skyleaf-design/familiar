/**
 Familiar: a macOS status bar host for the LHVM runtime.
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
import Result
import ServiceManagement

extension Notification.Name {
  static let close_launcher = Notification.Name("close_launcher")
}

let launcher_app_id = "com.skyleafdesign.familiar-launcher"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusItem = NSStatusBar.system.statusItem(withLength: 28.0)
  
  var queue: SKQueue?
  var queue_delegate: SKQueueDelegateForwarder?
  var system_delegate: WorkspaceDelegate?
  let popover = NSPopover()
  var click_detector: Any?
  var launcher_is_running = false
  var login_menu_item: NSMenuItem?
  var will_launch_at_login: Bool = false {
    didSet {
      self.update_menu_ui()
    }
  }
  
  func check_and_close_launcher() {
    // If the launcher is running, then it must have started at login.
    let apps = NSWorkspace.shared.runningApplications
    self.launcher_is_running = apps.filter { $0.bundleIdentifier == launcher_app_id }.count > 0
    
    // Start our launcher app at login
    SMLoginItemSetEnabled(launcher_app_id as CFString, true)
    
    // If WE are running, and the launcher is running, then we don't need it any more.
    guard self.launcher_is_running else { return }
    
    DistributedNotificationCenter.default().postNotificationName(
      .close_launcher,
      object: Bundle.main.bundleIdentifier,
      userInfo: nil,
      options: DistributedNotificationCenter.Options.deliverImmediately
    )
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    check_and_close_launcher()
    
    if let button = statusItem.button {
      button.image = #imageLiteral(resourceName: "familiar")
    }
    
    
    self.login_menu_item = NSMenuItem(title: "Start at login", action: #selector(self.toggle_login_start), keyEquivalent: "l")
    let launch_enabled = UserDefaults.standard.bool(forKey: "will_launch_at_login")
    self.login_menu_item!.state = launch_enabled ? .on : .off
    
    
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Git repo stream", action: #selector(AppDelegate.run_stream), keyEquivalent: "1"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(self.login_menu_item!)
    menu.addItem(NSMenuItem(title: "Quit Familiar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    statusItem.menu = menu
    
    popover.contentViewController = TextViewController._new()
    
    let messager = popover.contentViewController as! TextViewController
    
    // Create a function for each of the streams to open an populate the popover.
    let show_popover: MessageAction = { string in
      DispatchQueue.main.async {
        // @TODO: this runs before the VC is initialized: use a queue.
        messager.load_message(string)
        self.showPopover(sender: nil)
      }
    }
    
    
    let desktopDir = try? FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let test_url = URL(string: "myfile.txt", relativeTo: desktopDir)
    guard let the_test_url = test_url else { print("blah!"); return }
    let paths = [
      "/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist",
      "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist",
      the_test_url.path
    ]
    
    let file_streams: [FileChangedStream] = paths.map({ FileChangedStream($0, output_action: show_popover) })
    
    // Attach streams to a file system listener.
    queue_delegate = SKQueueDelegateForwarder(streams: file_streams)
    self.queue = SKQueue(delegate: self.queue_delegate!)
    for path in paths {
      self.queue!.addPath(path)
    }
    
    let generic_stream = GenericStream(output_action: show_popover)
    
    // Attach streams to a sleep/wake listener.
    system_delegate = WorkspaceDelegate(streams: [generic_stream])
    
    
    // Run the stream at application launch.
    generic_stream.run()
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func hidePopover() {
    popover.performClose(nil)
    guard let the_detector: Any = self.click_detector else { return }
    NSEvent.removeMonitor(the_detector)
    self.click_detector = nil
  }
  
  // Create a listener to close the popover when the user clicks.
  func showPopover(sender: Any?) {
    guard let button = statusItem.button else { return }
    guard self.click_detector == nil else { return }
    
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    self.click_detector = NSEvent.addGlobalMonitorForEvents(matching:[NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown], handler: { [weak self] event in
      self?.hidePopover()
    })
  }
  
  func update_menu_ui() {
    guard let menu_item = self.login_menu_item else { return }
    // Update the UI state of the button to reflect application state.
    menu_item.state = self.will_launch_at_login ? .on : .off
  }
  
  @objc func toggle_login_start() {
    // Mutate our own state to be the opposite of the current state.
    self.will_launch_at_login = !self.will_launch_at_login
    
    // Set login item status according to the will_login state.
    SMLoginItemSetEnabled(launcher_app_id as CFString, will_launch_at_login)
    
    // Save the login item state to user defaults, so our UI will reflect the SMLogin status
    // when the app is re-launched.
    UserDefaults.standard.set(self.will_launch_at_login, forKey: "will_launch_at_login")
  }
  
  func closePopover(sender: Any?) {
    popover.performClose(sender)
  }
  
  @objc func run_stream() {
    guard let generic_runner = self.system_delegate else { return }
    generic_runner.run_streams()
  }
}


