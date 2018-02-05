import Foundation
import AppKit

struct MessagePerceptor: Perceptor {
  typealias InputOutput = String
  
  var action: MessageAction
  
  init(show_message: @escaping MessageAction) {
    self.action = show_message
  }
}
