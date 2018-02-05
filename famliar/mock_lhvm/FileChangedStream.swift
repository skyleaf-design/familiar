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
