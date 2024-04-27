

import Cocoa


class ViewController: NSViewController {

  // MARK: - Outlets
    
    

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var setButton: NSButton!
  @IBOutlet weak var infoImageView: MyImageClass!
  @IBOutlet weak var InfoImageViewCell: NSImageCell!
    @IBAction func PasteMenuClicked(_ sender: NSMenuItem)
    {
        
    }
    @IBAction func DeleteListItem(_ sender:NSMenuItem)
    {
        let thisrow = tableView.selectedRow
        if (thisrow >= 1)
        {
            let lIndexSet = IndexSet(integer: thisrow)
            filesList.remove(at: thisrow)
            tableView.removeRows(at: lIndexSet)
        }
    }
    @IBAction func ClearListItems(_ sender: NSMenuItem)
    {
        filesList.removeAll()
        tableView.reloadData()
        do {
           try  FileManager.default.removeItem(atPath: urlForDataStorage()!.path)
        }
        catch {
            print("Error deleting file: \(error)")
        }
    }
   

    @IBAction func SaveMenuClicked(_ sender: NSMenuItem)
    {
        saveCurrentSelections()
    }
    
    @IBAction func CopyFileNameClicked (_ sender: NSMenuItem)
    {
        var selectedFile:String = " "
        let thisCell =  tableView.selectedRow
        print (filesList.count)
        if thisCell >= 0
        {
            selectedFile = filesList[thisCell].path
           
        }
        else
        {
            selectedFile = getDesktopImage()
            
        }
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([selectedFile as NSString])
       
    }
    @IBAction func CopyImageDataClicked (_ sender: NSMenuItem)
    {
        guard let ImageData = InfoImageViewCell.image else { return  }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([ImageData as NSImage])
        
    }
    
    @IBAction func PasteImageDataClicked (_ sender: NSMenuItem)
    {
        let pasteboard = NSPasteboard.general
        let imageData =  (pasteboard.readObjects(forClasses: [NSImage.self]) ) as? [NSImage]
        if (imageData?.count ?? 0 > 0)
        {
            infoImageView.image = imageData?[0]
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = paths.appendingPathComponent("preview.png")
            saveImage(image: infoImageView.image!, tFilename: filename as NSURL)
        }
    }
    
    @IBAction func viewWallpaper (_ sender: NSMenuItem)
    {
        let ThatFile=getDesktopImage()
        
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: ThatFile)])
        
    }
    func saveImage(image: NSImage, tFilename: NSURL)
    {
        
        let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
        let pngData = imageRep?.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
        do {
            try pngData?.write(to: tFilename as URL )
        }
        catch
        {
            return
            
        }
    }
    
    
    
    @IBAction func ShowListClicked(_ sender: NSMenuItem)
    {
        let currData = tableView.dataSource
    }
    
    @IBOutlet weak var canSave: NSButtonCell!
    
    @IBOutlet weak var edtFileName: NSTextField!
    // MARK: - Properties

  var filesList: [URL] = []
  var showInvisibles = false
    var selectedImage:String = ""
    

  var selectedFolder: URL? {
    didSet {
      if let selectedFolder = selectedFolder {
         
          if !(selectedFolder.hasDirectoryPath)
          {
              
             selectedItem = selectedFolder
              selectedImage = selectedFolder.path
              previewImage=selectedImage
          }
          else
          {
              filesList = contentsOf(folder: selectedFolder)
              selectedItem = nil
              self.tableView.reloadData()
              self.tableView.scrollRowToVisible(0)
              setButton.isEnabled = true
              view.window?.title = selectedFolder.path
          }
      } else {
        setButton.isEnabled = false
        view.window?.title = "Randomise Desktop"
      }
    }
  }

  var selectedItem: URL? {
    didSet {
     // saveInfoButton.isEnabled = false
    
        if self.selectedItem == nil
        {
          return
        }
     
        //view.window?.title = self.selectedImage
       // self.edtFileName.cell?.title=self.selectedImage
        let image = NSImage(contentsOfFile: self.selectedImage)
        infoImageView.image=image
    
    }
  }
    
    var previewImage:String? {
        didSet
        {
           let  tImageName = previewImage ?? ""
            view.window?.title = tImageName
            let image = NSImage(contentsOfFile: tImageName )
            if (image != nil) 
            {
                infoImageView.image=image
            }
            else
            {
                return
            }
            
        }
    }

   
   
    

  // MARK: - View Lifecycle & error dialog utility

  override func viewWillAppear() {
    super.viewWillAppear()
      infoImageView.setTable(tTable: &filesList)
    
    
      
    restoreCurrentSelections()
      let menu = NSMenu()
      let ViewSubMenu = NSMenuItem()
      menu.addItem(NSMenuItem(title: "Copy Filename", action: #selector(tableContextItemClicked(_:)), keyEquivalent: ""))
      menu.addItem(NSMenuItem(title: "Copy Image Data", action: #selector(tableContextItemClicked(_:)), keyEquivalent: ""))
      
      menu.addItem(.separator())
      ViewSubMenu.title="View with"
      ViewSubMenu.submenu = NSMenu(title: "View with")
      ViewSubMenu.submenu?.addItem(withTitle: "Finder", action: #selector(tableContextItemClicked(_:)), keyEquivalent: "")
      
      menu.addItem(ViewSubMenu)
      
      menu.addItem(NSMenuItem(title: "Delete", action: #selector(tableContextItemClicked(_:)), keyEquivalent: ""))
      tableView.menu = menu
     
      
     
  }

    @objc private func tableContextItemClicked(_ sender: NSMenuItem) {

        
        switch sender.title {
        case "Copy Filename":
            CopyFileNameClicked(sender)
            break
        case "Copy Image Data":
            CopyImageDataClicked(sender)
            break
        default:
            return
        }
        print (sender.title)
        guard tableView.clickedRow >= 0 else { return }

        let item = tableView.clickedRow
        
        //showDetailsViewController(with: item)
    }

   

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        previewImage=getDesktopImage()
    }
   

  override func viewWillDisappear() {
    saveCurrentSelections()

    super.viewWillDisappear()
  }

  func showErrorDialogIn(window: NSWindow, title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .critical
    alert.beginSheetModal(for: window, completionHandler: nil)
  }

}


// MARK: - Getting file or folder information

extension ViewController {

  func contentsOf(folder: URL) -> [URL] {
      // 1
       let fileManager = FileManager.default

       // 2
       do {
         // 3
           let contents = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
           let images = contents.filter{ $0.pathExtension == "png" || $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" || $0.pathExtension == "webp"
           }

           let urls = images.map { return $0 }
         return urls
       }
      catch
      {
         return []
      }
  }



  func formatInfoText(_ text: String) -> NSAttributedString {
      let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
    paragraphStyle?.minimumLineHeight = 24
    paragraphStyle?.alignment = .left
    paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 240) ]

    let textAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14),
        NSAttributedString.Key.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default
    ]

    let formattedText = NSAttributedString(string: text, attributes: textAttributes)
    return formattedText
  }
func setDesktopImage(url: URL) {
    do {
        if let screen = NSScreen.main
            {
            var options: [NSWorkspace.DesktopImageOptionKey: Any] = [:]
            options[.imageScaling] = NSNumber(value:NSImageScaling.scaleProportionallyUpOrDown.rawValue)
            
                try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: options)
            
            }
        }
    catch {
                print(error)
          }
        }

}
func getDesktopImage() -> String
{
    
    if let screen = NSScreen.main
    {
        let img = NSWorkspace.shared.desktopImageURL(for: screen)?.path ?? " "
        return img
    }
    return "naffink"
    
    
}

// MARK: - Actions

extension ViewController {

    @IBAction func copyFilePath(_ sender: Any)
    {
        
    }
  @IBAction func selectFolderClicked(_ sender: Any)
  {
      guard let window = view.window else {return}
      
      let Panel = NSOpenPanel()
      Panel.canChooseFiles=true
      Panel.canChooseDirectories=true
      Panel.allowsMultipleSelection=false
      
      
      Panel.beginSheetModal(for: window) { (result) in
          if result == NSApplication.ModalResponse.OK {
          // 4
          self.selectedFolder = Panel.urls[0]
              
        }
      }
  }

  @IBAction func toggleShowInvisibles(_ sender: NSButton) {
  }

  @IBAction func tableViewDoubleClicked(_ sender: Any) {
      print ("doubleclicked")
      if self.selectedImage != ""
      {
          setClicked(sender)
      }
  }

  @IBAction func setClicked(_ sender: Any) {
      if (self.selectedImage != "")
      {
          setDesktopImage(url: URL(fileURLWithPath: self.selectedImage))
      }
  }
    @IBAction func randomiseClicked(_ sender: Any)
    {
        let rowcount = self.numberOfRows(in: tableView)
        if (rowcount>0)
        {
            let randomInt = Int.random(in: 0..<rowcount)
            let randomFile = filesList[randomInt].path
            previewImage = randomFile
            filesList.remove(at: randomInt)
            let indexSet = IndexSet(integer: randomInt)
            tableView.removeRows(at: indexSet, withAnimation: .slideUp)
            setDesktopImage(url: URL(fileURLWithPath: randomFile) )
        }
    }

  @IBAction func saveInfoClicked(_ sender: Any) {
  }

}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return filesList.count
  }

}


// MARK: - NSTableViewDelegate

extension ViewController: NSTableViewDelegate {
 
  func tableView(_ tableView: NSTableView, viewFor
    tableColumn: NSTableColumn?, row: Int) -> NSView? {
      
      
      let item = filesList[row]
      let itemPath = item.path
      let fileIcon = NSWorkspace.shared.icon(forFile: itemPath)
      if let cell = tableView.makeView(withIdentifier:  NSUserInterfaceItemIdentifier(rawValue:"FileCell") , owner: nil)
            as? NSTableCellView {
          // 4
          cell.textField?.stringValue = item.lastPathComponent
          cell.imageView?.image = fileIcon
          return cell
        }

    return nil
  }

   
    func tableViewSelectionDidChange(_ notification: Notification) {
    if tableView.selectedRow < 0 {
      selectedItem = nil
      return
    }
        self.selectedImage = filesList[tableView.selectedRow].path //.components(separatedBy: "//")[1]
        selectedItem = URL(fileURLWithPath: self.selectedImage)
  }

}

// MARK: - Save & Restore previous selection

extension ViewController {

  func saveCurrentSelections() {
    guard let dataFileUrl = urlForDataStorage() else { return }
      if (filesList.count > 0){
          if (canSave.state == NSControl.StateValue.on)
          {
              let fm = FileManager.default
            
              if (!fm.fileExists(atPath: dataFileUrl.path))
              {
                  FileManager.default.createFile(atPath: dataFileUrl.path, contents: Data(" ".utf8))
              }
              let listfileHandle = FileHandle(forWritingAtPath: dataFileUrl.path)
              
            
              let filesToDump = filesList.map({return($0.path+"\n")})
              for fileToDump in filesToDump
              {
                  if fileToDump != getDesktopImage()+"\n"
                  {
                      listfileHandle?.write(fileToDump.data(using: .utf8)!)
                      
                  }
              }
              //try? filesList.write(to: dataFileUrl, atomically: true, encoding: .utf8)
              listfileHandle?.closeFile()
          }
      }
      else
      {
          return
      }

  }

  func restoreCurrentSelections() {
    guard let dataFileUrl = urlForDataStorage() else { return }
      if !FileManager.default.fileExists(atPath: dataFileUrl.path)
      {
          return
          
      }

    do {
      let storedData = try String(contentsOf: dataFileUrl)
        let storedDataComponents = storedData.components(separatedBy: "\n")
      if storedDataComponents.count >= 1
        {
          filesList.removeAll()
          let wallpaper = getDesktopImage()
          if wallpaper != "naffink"
            
          {
              let theUrl:URL = URL(fileURLWithPath: wallpaper)
              filesList.append(theUrl)
          }
        
          for dataComponent in storedDataComponents
          {
            
                  filesList.append(URL(fileURLWithPath: dataComponent))
              
              
          }
          self.tableView.reloadData()
          self.tableView.scrollRowToVisible(0)
        }
    } catch {
      print(error)
    }
  }

  private func selectUrlInTable(_ url: URL?) {
    guard let url = url else {
      tableView.deselectAll(nil)
      return
    }

      if let rowNumber = filesList.firstIndex(of: url) {
      let indexSet = IndexSet(integer: rowNumber)
      DispatchQueue.main.async {
        self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
      }
    }
  }
  
  private func urlForDataStorage() -> URL? {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      let documentsDirectory = paths[0]
          .path+"/RandomiseDesktop.conf"
          return URL(fileURLWithPath: documentsDirectory)
    
  }

}
