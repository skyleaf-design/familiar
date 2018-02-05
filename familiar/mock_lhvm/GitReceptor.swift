import Foundation
import SwiftGit2


struct GitReceptor: Receptor {
  typealias InputOutput = String
  
  let root_path: String
  init (root_path path: String) {
    self.root_path = path
  }
  
  func query(_ current_path: String) -> String? {
    // Note: we don't even need to consider the current_path passed in to us.
    return are_repositories_dirty(at_path: self.root_path)
  }
  
  func are_repositories_dirty(at_path path: String) -> String? {
    let filer = FileManager.default
    let options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
    let url = URL(fileURLWithPath: path)
    var found_dirty = false
    var strings = [String()]
    
    do {
      let directory_urls = try filer.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: options)
      for url in directory_urls {
        let repo_try = Repository.at(url)
        guard let _ = repo_try.value else { continue }
        let result = execute(command: "git", arguments: ["-C", url.path, "diff", "--shortstat"])
        guard !result.isEmpty else { continue }
        found_dirty = true
        strings.append("\(url.lastPathComponent) is NOT clean!")
      }
    } catch {
      print("Oh my gosh!!")
    }
    
    return found_dirty ? strings.joined(separator: "\n") : nil
  }
  
  private func execute(command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
  }
  
  private func shell(launchPath: String, arguments: [String]) -> String {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    if output.characters.count > 0 {
      // Remove newline.
      let lastIndex = output.index(before: output.endIndex)
      return String(output[output.startIndex ..< lastIndex])
    }
    return output
  }
}
