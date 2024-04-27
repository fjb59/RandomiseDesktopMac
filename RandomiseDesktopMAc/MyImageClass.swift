//
//  MyImageClass.swift
//  RandomiseDesktopMAc
//
//  Created by frank on 26/04/2024.
//

import Cocoa

class MyImageClass: NSImageView {
    private var  table:[URL]?
    
    var filesArray:[URL] = []
 
    func setTable (tTable : inout [URL])
    {
        table=tTable
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
       //super.draggingEntered(sender)
    //    let thisColour = self.layer?.backgroundColor
        filesArray=[]

        let board = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType"))
        if (board != nil)
        {
            //self.layer?.backgroundColor=NSColor.green.cgColor
            return .link
        }
        else
        {
            
            return super.draggingEntered(sender)
        }
    }
    override func draggingExited(_ sender: NSDraggingInfo?) {
        super.draggingExited(sender)
    }
    override func draggingEnded(_ sender: NSDraggingInfo) {
        super.draggingEnded(sender)
    }
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        super.draggingUpdated(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path:String = pasteboard[0] as? String
            else
            {
                return false
            
            }
        
        let fileURL: URL = (URL(fileURLWithPath: path) )
        table?.append(fileURL)

            //GET YOUR FILE PATH !!!
          

            return true
        }
    
    
    
}