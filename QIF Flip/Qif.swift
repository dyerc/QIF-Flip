//
//  Qif.swift
//  QIF Flip
//
//  Created by Chris Dyer on 13/09/2017.
//  Copyright © 2017 Chris Dyer. All rights reserved.
//

import Foundation

class Qif: NSObject {
  var filePath: String?
  
  //let regexPattern = "T(\\d|\\.|\\-)+"
  let regexPattern = "T(-?\\d+\\.\\d+)"
  
  init(filePath: String) {
    self.filePath = filePath
  }
  
  func flipped() -> String? {
    if let data = read() {
      var blocks = data.split(separator: "^").map(String.init)
      
      for i in 0..<blocks.count {
        blocks[i] = flipTransaction(block: blocks[i])
      }
      
      // Return joined with a trailing separator
      return blocks.joined(separator: "^") + "^"
    } else {
      return nil
    }
  }
  
  func write(url: URL) -> Bool {
    if let converted = flipped() {
      do {
        try converted.write(to: url, atomically: false, encoding: String.Encoding.utf8)
        return true
      } catch {
        return false
      }
    } else {
      return false
    }
  }
  
  private func flipTransaction(block: String) -> String {
    if let regex = try? NSRegularExpression(pattern: regexPattern, options: []) {
      let t = regex.firstMatch(in: block, options: [], range: NSMakeRange(0, block.characters.count))
      if let range = t?.rangeAt(1) {
        let nsBlock = block as NSString
        return nsBlock.replacingCharacters(in: range, with: flipValue(val: nsBlock.substring(with: range))) as String
      } else {
        return block
      }
    } else {
      return block
    }
  }
  
  // Convert string to float, * -1, return as string
  private func flipValue(val: String) -> String {
    if let numVal = Float(val) {
      return String(format: "%.02f", numVal * -1)
    } else {
      return val
    }
  }
    
  private func read() -> String? {
    if let filePath = self.filePath {
      do {
        return try String(contentsOfFile: filePath)
      } catch {
        return nil
      }
    } else {
      return nil
    }
  }
}
