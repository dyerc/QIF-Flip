//
//  DropView.swift
//  QIF Flip
//
//  Created by Chris Dyer on 13/09/2017.
//  Copyright © 2017 Chris Dyer. All rights reserved.
//

import Cocoa

class DropView: NSView {
  var filePath: String?
  
  var hovering = false
  let validExtensions = ["qif", "txt"]
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType])
  }
  
  func flip(filePath: String) {
    let fileUrl = URL.init(fileURLWithPath: filePath)
    let qif = Qif(filePath: filePath)
    
    let panel = NSSavePanel()
    panel.allowedFileTypes = ["qif"]
    panel.nameFieldStringValue = fileUrl.lastPathComponent + ".converted"
    
    panel.begin { (result) in
      if result == NSFileHandlingPanelOKButton {
        if let url = panel.url {
          if qif.write(url: url) == false {
            let alert = NSAlert()
            alert.messageText = "An error occurred saving the file"
            alert.runModal()
          }
        }
      }
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let dropRect = NSBezierPath(roundedRect: NSMakeRect(10, 10, self.bounds.width - 20, self.bounds.height - 20), xRadius: 10, yRadius: 10)
    
    if hovering {
      NSColor.orange.set()
    } else {
      NSColor.gray.set()
    }
    
    dropRect.lineWidth = 3
    let pattern: [CGFloat] = [20.0, 10.0]
    dropRect.setLineDash(pattern, count: 2, phase: 0.0)
    dropRect.stroke()
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if validateExtension(sender) == true {
      self.hovering = true
      self.needsDisplay = true
      return .copy
    } else {
      return NSDragOperation()
    }
  }
  
  override func mouseDown(with event: NSEvent) {
    let openPanel = NSOpenPanel()
    if openPanel.runModal() == NSModalResponseOK {
      if let u = openPanel.url {
        flip(filePath: u.path)
      }
    }
  }
  
  func validateExtension(_ drag: NSDraggingInfo) -> Bool {
    guard let board = drag.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray,
      let path = board[0] as? String
      else { return false}
    
    let suffix = URL(fileURLWithPath: path).pathExtension
    for ext in self.validExtensions {
      if ext.lowercased() == suffix {
        return true
      }
    }
    
    return false
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
    self.hovering = false
    self.needsDisplay = true
  }
  
  override func draggingEnded(_ sender: NSDraggingInfo?) {
    self.hovering = false
    self.needsDisplay = true
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard let board = sender.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray,
      let path = board[0] as? String
      else { return false}
    
    self.filePath = path
    Swift.print("QIF File: \(String(describing: filePath))")
    
    if let path = filePath {
      flip(filePath: path)
    }
    
    return true
  }
}
