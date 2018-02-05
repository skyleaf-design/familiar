import Foundation

class SKQueueDelegateForwarder: SKQueueDelegate {
  let streams: [FileChangedStream]
  init(streams: [FileChangedStream]) {
    self.streams = streams
  }
  
  func receivedNotification(_ notification: SKQueueNotification, path: String, queue: SKQueue) {
    for stream in streams {
      stream.run(triggered_path: path)
    }
  }
}
