

import Cocoa

class ViewController: NSViewController {

  // MARK: - Outlets

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var saveInfoButton: NSButton!
  @IBOutlet weak var setButton: NSButton!
  @IBOutlet weak var infoImageView: NSImageView!
  @IBOutlet weak var InfoImageViewCell: NSImageCell!
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
      saveInfoButton.isEnabled = false
    
        if self.selectedItem == nil
        {
          return
        }
      guard let selectedUrl = selectedItem else {
        return
      }
        view.window?.title = self.selectedImage
        let image = NSImage(contentsOfFile: self.selectedImage)
        infoImageView.image=image
      let infoString = infoAbout(url: selectedUrl)
      if !infoString.isEmpty {
        let formattedText = formatInfoText(infoString)
     //   infoTextView.textStorage?.setAttributedString(formattedText)
        saveInfoButton.isEnabled = true
      }
    }
  }
    
    var previewImage:String? {
        didSet
        {
            view.window?.title = previewImage ?? ""
             let image = NSImage(contentsOfFile: previewImage ?? "")
            infoImageView.image=image
            
        }
    }
    

  // MARK: - View Lifecycle & error dialog utility

  override func viewWillAppear() {
    super.viewWillAppear()
    
      
    restoreCurrentSelections()
     
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
           let images = contents.filter{ $0.pathExtension == "png" || $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" 
           }

           let urls = images.map { return folder.appendingPathComponent($0.path) }
         return urls
       }
      catch
      {
         return []
      }
  }

  func infoAbout(url: URL) -> String {
      let fileManager = FileManager.default

        // 2
        do {
          // 3
            let thispath = url.relativePath
            let attributes = try fileManager.attributesOfItem(atPath: thispath)
          var report: [String] = ["\(url.path)", ""]

          // 4
          for (key, value) in attributes {
            // ignore NSFileExtendedAttributes as it is a messy dictionary
            if key.rawValue == "NSFileExtendedAttributes" { continue }
            report.append("\(key.rawValue):\t \(value)")
          }
          // 5
          return report.joined(separator: "\n")
        } catch {
          // 6
          return "No information available for \(url.path)"
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
            let randomFile = "/" + filesList[randomInt].path.components(separatedBy: "//")[1]
            previewImage = randomFile
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
      let itemPath = "/"+item.path.components(separatedBy: "//")[1]
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
    let selectedthing = filesList[tableView.selectedRow].path.components(separatedBy: "//")[1]
        self.selectedImage="/"+selectedthing
        print (URL(fileURLWithPath: self.selectedImage))
        selectedItem = URL(fileURLWithPath: self.selectedImage)
  }

}

// MARK: - Save & Restore previous selection

extension ViewController {

  func saveCurrentSelections() {
    guard let dataFileUrl = urlForDataStorage() else { return }

    let parentForStorage = selectedFolder?.path ?? ""
    let fileForStorage = selectedItem?.path ?? ""
    let completeData = "\(parentForStorage)\n\(fileForStorage)\n"

    try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
  }

  func restoreCurrentSelections() {
    guard let dataFileUrl = urlForDataStorage() else { return }

    do {
      let storedData = try String(contentsOf: dataFileUrl)
      let storedDataComponents = storedData.components(separatedBy: .newlines)
      if storedDataComponents.count >= 2 {
        if !storedDataComponents[0].isEmpty {
          selectedFolder = URL(fileURLWithPath: storedDataComponents[0])
          if !storedDataComponents[1].isEmpty {
            selectedItem = URL(fileURLWithPath: storedDataComponents[1])
            selectUrlInTable(selectedItem)
          }
        }
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
    return nil
  }

}
