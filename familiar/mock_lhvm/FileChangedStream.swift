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

struct FileChangedStream {
  private let r_1: FileChangedReceptor
  private let r_2: GitReceptor
  private let t_1: GitPathTransform
  private let p_1: MessagePerceptor
  
  init(_ path: String, output_action action: @escaping MessageAction) {
    r_1 = FileChangedReceptor(watched_path: path)
    r_2 = GitReceptor(root_path: "/Users/raphael/Developer")
    t_1 = GitPathTransform()
    p_1 = MessagePerceptor(show_message: action)
  }
  
  func run(triggered_path path: String) {
    guard r_1.query(path) != nil else { return }
    guard let dirty_repo_paths = r_2.query("") else { return }
    let message = t_1.transform(dirty_repo_paths)
    p_1.action(dirty_repo_paths)
  }
}
