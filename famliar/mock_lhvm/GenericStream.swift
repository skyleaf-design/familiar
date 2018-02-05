import Foundation

struct GenericStream {
  private let r_1: GitReceptor
  private let t_1: GitPathTransform
  private let p_1: MessagePerceptor
  
  init(output_action action: @escaping MessageAction) {
    r_1 = GitReceptor(root_path: "/Users/raphael/Developer")
    t_1 = GitPathTransform()
    p_1 = MessagePerceptor(show_message: action)
  }
  
  func run() {
    guard let dirty_repo_paths = r_1.query("") else { return }
    let message = t_1.transform(dirty_repo_paths)
    p_1.action(dirty_repo_paths)
  }
}

