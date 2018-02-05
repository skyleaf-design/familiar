import Cocoa
import Result

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusItem = NSStatusBar.system.statusItem(withLength: 28.0)
  
  var queue: SKQueue?
  var queue_delegate: SKQueueDelegateForwarder?
  var system_delegate: WorkspaceDelegate?
  let popover = NSPopover()
  var click_detector: Any?
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if let button = statusItem.button {
      button.image = #imageLiteral(resourceName: "familiar")
    }
    
    constructMenu()
    
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
  }
  
  func showPopover(sender: Any?) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
    // Create a listener to close the popover when the user clicks.
    self.click_detector = NSEvent.addGlobalMonitorForEvents(matching:[NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown], handler: { [weak self] event in
      self?.hidePopover()
    })
  }
  
  func closePopover(sender: Any?) {
    popover.performClose(sender)
  }
  
  @objc func run_stream() {
    guard let generic_runner = self.system_delegate else { return }
    generic_runner.run_streams()
  }
  
  func constructMenu() {
    let menu = NSMenu()
    
    menu.addItem(NSMenuItem(title: "Git repo stream", action: #selector(AppDelegate.run_stream), keyEquivalent: "1"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit Familiar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    
    statusItem.menu = menu
  }
}


