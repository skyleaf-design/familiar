import Cocoa

class TextViewController: NSViewController {
  func display_message() {
    guard message_queue.count > 0 else { return }
    self.text_field.stringValue = message_queue.removeFirst()
  }
  func load_message(_ message: String) {
    self.message_queue += [message]
    guard self.text_field != nil else { return }
    self.display_message()
  }
  
  private var message_queue = [String]()

  @IBOutlet weak var text_field: NSTextField!
  
  override func viewDidLoad() {
    self.display_message()
  }
}

extension TextViewController {
  static func _new() -> TextViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier(rawValue: "TextViewController")
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? TextViewController else {
      fatalError("Could not instantiate a view controller from the storyboard.")
    }
    return viewcontroller
  }
}
