import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = root.appendingPathComponent("AppBundle/SleepTimer.iconset", isDirectory: true)
let icnsURL = root.appendingPathComponent("AppBundle/AppIcon.icns")

let sizes: [(name: String, points: CGFloat, scale: CGFloat)] = [
    ("icon_16x16.png", 16, 1),
    ("icon_16x16@2x.png", 16, 2),
    ("icon_32x32.png", 32, 1),
    ("icon_32x32@2x.png", 32, 2),
    ("icon_128x128.png", 128, 1),
    ("icon_128x128@2x.png", 128, 2),
    ("icon_256x256.png", 256, 1),
    ("icon_256x256@2x.png", 256, 2),
    ("icon_512x512.png", 512, 1),
    ("icon_512x512@2x.png", 512, 2)
]

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let corner = size * 0.23
    let bg = NSBezierPath(roundedRect: rect, xRadius: corner, yRadius: corner)

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.17, green: 0.27, blue: 0.55, alpha: 1),
        NSColor(calibratedRed: 0.11, green: 0.16, blue: 0.30, alpha: 1)
    ])!
    gradient.draw(in: bg, angle: -90)

    NSGraphicsContext.current?.saveGraphicsState()
    bg.addClip()

    let glowRect = NSRect(
        x: size * 0.15,
        y: size * 0.48,
        width: size * 0.7,
        height: size * 0.42
    )
    let glow = NSGradient(colors: [
        NSColor(calibratedRed: 0.42, green: 0.78, blue: 0.97, alpha: 0.65),
        NSColor(calibratedRed: 0.42, green: 0.78, blue: 0.97, alpha: 0.02)
    ])!
    glow.draw(in: NSBezierPath(ovalIn: glowRect), relativeCenterPosition: .zero)
    NSGraphicsContext.current?.restoreGraphicsState()

    let moonSize = size * 0.34
    let moonRect = NSRect(x: size * 0.24, y: size * 0.48, width: moonSize, height: moonSize)
    NSColor(calibratedRed: 0.99, green: 0.86, blue: 0.50, alpha: 1).setFill()
    NSBezierPath(ovalIn: moonRect).fill()

    NSColor(calibratedRed: 0.17, green: 0.27, blue: 0.55, alpha: 1).setFill()
    let cutoutRect = moonRect.offsetBy(dx: moonSize * 0.22, dy: moonSize * 0.02)
    NSBezierPath(ovalIn: cutoutRect).fill()

    let clockRect = NSRect(x: size * 0.28, y: size * 0.20, width: size * 0.44, height: size * 0.44)
    let clockPath = NSBezierPath(ovalIn: clockRect)
    NSColor.white.withAlphaComponent(0.92).setFill()
    clockPath.fill()

    NSColor(calibratedRed: 0.16, green: 0.21, blue: 0.38, alpha: 0.16).setStroke()
    clockPath.lineWidth = max(1, size * 0.018)
    clockPath.stroke()

    let center = NSPoint(x: clockRect.midX, y: clockRect.midY)
    let minuteHand = NSBezierPath()
    minuteHand.lineWidth = max(1.5, size * 0.03)
    minuteHand.lineCapStyle = .round
    minuteHand.move(to: center)
    minuteHand.line(to: NSPoint(x: center.x, y: center.y + size * 0.12))
    NSColor(calibratedRed: 0.16, green: 0.21, blue: 0.38, alpha: 0.92).setStroke()
    minuteHand.stroke()

    let hourHand = NSBezierPath()
    hourHand.lineWidth = max(1.5, size * 0.03)
    hourHand.lineCapStyle = .round
    hourHand.move(to: center)
    hourHand.line(to: NSPoint(x: center.x + size * 0.08, y: center.y + size * 0.05))
    hourHand.stroke()

    NSColor(calibratedRed: 0.98, green: 0.78, blue: 0.32, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: center.x - size * 0.025, y: center.y - size * 0.025, width: size * 0.05, height: size * 0.05)).fill()

    func drawStar(x: CGFloat, y: CGFloat, radius: CGFloat) {
        let path = NSBezierPath()
        let points = 4
        for index in 0..<(points * 2) {
            let angle = (CGFloat(index) * .pi / CGFloat(points)) - (.pi / 2)
            let r = index.isMultiple(of: 2) ? radius : radius * 0.42
            let point = NSPoint(x: x + cos(angle) * r, y: y + sin(angle) * r)
            if index == 0 {
                path.move(to: point)
            } else {
                path.line(to: point)
            }
        }
        path.close()
        path.fill()
    }

    NSColor.white.withAlphaComponent(0.9).setFill()
    drawStar(x: size * 0.74, y: size * 0.78, radius: size * 0.04)
    drawStar(x: size * 0.82, y: size * 0.66, radius: size * 0.025)

    image.unlockFocus()
    return image
}

for item in sizes {
    let pixelSize = item.points * item.scale
    let image = drawIcon(size: pixelSize)
    guard
        let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        let png = rep.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "SleepTimerIcon", code: 1)
    }

    try png.write(to: iconsetURL.appendingPathComponent(item.name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    throw NSError(domain: "SleepTimerIcon", code: Int(process.terminationStatus))
}

print("Generated \(icnsURL.path)")
