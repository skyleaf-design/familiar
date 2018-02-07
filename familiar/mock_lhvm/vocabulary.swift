/**
 Familiar: a macOS status bar host for the LHVM runtime.
 Copyright (C) 2018 Raphael Spencer
 
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
