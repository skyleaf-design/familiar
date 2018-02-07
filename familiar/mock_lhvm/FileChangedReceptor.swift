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

struct FileChangedReceptor: Receptor {
  typealias InputOutput = String
  
  func query(_ current_path: String) -> String? {
    guard current_path == watched_path else { return nil }
    defer { cache_file(current_path) }
    return file_changed(current_path) ? "unused string" : nil
  }
  
  let watched_path: String
  init(watched_path path: String) {
    self.watched_path = path
  }
  
  private func cache_file(_ path: String) {
    let url = URL(fileURLWithPath: path)
    let file_name = url.lastPathComponent
    let file_manager = FileManager.default
    let currentPath = file_manager.currentDirectoryPath
    let next_url = URL(fileURLWithPath: [currentPath, file_name].joined(separator: "/"))
    
    do {
      //try file_manager.copyItem(at: url, to: next_url)
      let contents = try String(contentsOf: url)
      try contents.write(to: next_url, atomically: true, encoding: .utf8)
    } catch {
      print("Could not copy the watched file")
    }
  }
  
  private func file_changed(_ path_to_mutated: String) -> Bool {
    let source_url = URL(fileURLWithPath: path_to_mutated)
    let file_name = source_url.lastPathComponent
    
    let file_manager = FileManager.default
    let current_directory = file_manager.currentDirectoryPath
    let path_to_last_seen = [current_directory, file_name].joined(separator: "/")
    let has_changed = !file_manager.contentsEqual(atPath: path_to_mutated, andPath: path_to_last_seen)
    return has_changed
  }
}
