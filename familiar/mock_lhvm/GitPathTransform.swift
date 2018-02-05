import Foundation

struct GitPathTransform: Transform {
  typealias InputOutput = String
  
  func transform(_ path: String) -> String {
    return path
  }
}
