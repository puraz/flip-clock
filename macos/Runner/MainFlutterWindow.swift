import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // 隐藏标题栏左上角的三个按钮（关闭、最小化、缩放）
    DispatchQueue.main.async { [weak self] in
      self?.standardWindowButton(.closeButton)?.isHidden = true
      self?.standardWindowButton(.miniaturizeButton)?.isHidden = true
      self?.standardWindowButton(.zoomButton)?.isHidden = true
    }
  }
}
