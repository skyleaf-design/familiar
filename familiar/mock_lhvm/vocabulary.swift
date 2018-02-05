protocol Receptor {
  associatedtype InputOutput
  func query(_: InputOutput) -> InputOutput?
}
protocol Transform {
  associatedtype InputOutput
  func transform(_: InputOutput) -> InputOutput
}
protocol Perceptor {
  associatedtype InputOutput
  var action: (_: InputOutput) -> Void { get set }
}

typealias MessageAction = (String) -> Void
