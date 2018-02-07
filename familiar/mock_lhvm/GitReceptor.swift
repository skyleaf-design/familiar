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
    var found_local = false
    var found_detached = false
    var strings = [String()]
    
    do {
      let directory_urls = try filer.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: options)
      for url in directory_urls {
        let repo_try = Repository.at(url)
        guard let repo = repo_try.value else { continue }
        
        // First, check if the repo is dirty.
        let result = execute(command: "git", arguments: ["-C", url.path, "diff", "--shortstat"])
        guard result.isEmpty else {
          found_dirty = true
          strings.append("\(url.lastPathComponent) is NOT clean!")
          continue
        }
        
        // Second, check if the repo is in "detached" state, which means that it has
        // no remote repositories set up.
        guard let remotes = repo.allRemotes().value else { continue } // Error condition.
        guard remotes.count > 0 else {
          found_detached = true
          strings.append("\(url.lastPathComponent) has no remote repository!")
          continue
        }
        
        // Check that the HEAD branch contains no unpublished commits.
        let pushed_commits = execute(command: "git", arguments: ["log", "@push..", "--oneline"])
        guard pushed_commits.count == 0 else {
          found_local = true
          strings.append("\(url.lastPathComponent) has no main branch!")
          continue
        }
      }
    } catch {
      print("Oh my gosh!!")
    }
    
    return found_dirty || found_local || found_detached ? strings.joined(separator: "\n") : nil
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
