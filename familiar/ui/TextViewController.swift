/**
 Familiar: a macOS status bar host for the LHVM runtime.
 Copyright (C) 2018 Raphael Spencer
 
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
