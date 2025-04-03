import SwiftUI

@available(macOS 14.0, *)
struct CHRCanvasView: NSViewRepresentable {
    @Binding var pixels: [[UInt8]]  // 0=transparent, 1=light, 2=medium, 3=dark
    @Binding var selectedColor: UInt8
    @Binding var zoom: CGFloat
    
    func makeNSView(context: Context) -> CHRCanvas {
        let canvas = CHRCanvas(pixels: $pixels, selectedColor: $selectedColor, zoom: $zoom)
        return canvas
    }
    
    func updateNSView(_ nsView: CHRCanvas, context: Context) {
        nsView.pixels = $pixels
        nsView.selectedColor = $selectedColor
        nsView.zoom = $zoom
        nsView.needsDisplay = true
    }
}

class CHRCanvas: NSView {
    var pixels: Binding<[[UInt8]]>
    var selectedColor: Binding<UInt8>
    var zoom: Binding<CGFloat>
    
    init(pixels: Binding<[[UInt8]]>, selectedColor: Binding<UInt8>, zoom: Binding<CGFloat>) {
        self.pixels = pixels
        self.selectedColor = selectedColor
        self.zoom = zoom
        super.init(frame: .zero)
        
        // Set up the view
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor
        
        // Add mouse tracking
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Draw pixels
        let pixelSize = 8 * zoom.wrappedValue
        for row in 0..<8 {
            for col in 0..<8 {
                let x = CGFloat(col) * pixelSize
                let y = CGFloat(7 - row) * pixelSize
                let rect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)
                
                // Draw pixel color
                let color: NSColor
                switch pixels.wrappedValue[row][col] {
                case 0: color = .clear
                case 1: color = NSColor(white: 0.8, alpha: 1.0)  // Light gray
                case 2: color = NSColor(white: 0.5, alpha: 1.0)  // Medium gray
                case 3: color = NSColor(white: 0.2, alpha: 1.0)  // Dark gray
                default: color = .clear
                }
                
                context.setFillColor(color.cgColor)
                context.fill(rect)
                
                // Draw grid
                context.setStrokeColor(NSColor.gray.withAlphaComponent(0.3).cgColor)
                context.stroke(rect)
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        handleMouseEvent(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        handleMouseEvent(event)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let pixelSize = 8 * zoom.wrappedValue
        
        let col = Int(location.x / pixelSize)
        let row = 7 - Int(location.y / pixelSize)
        
        guard row >= 0 && row < 8 && col >= 0 && col < 8 else { return }
        
        pixels.wrappedValue[row][col] = selectedColor.wrappedValue
        needsDisplay = true
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        needsDisplay = true
    }
} 