import Foundation
import AppKit

struct Section {
    let title: String
    let body: String
    let fillColor: NSColor
}

let outputPath = "/Users/yuslam/Academy/CBL01/AppruvQR/output/pdf/appruvqr_repo_summary.pdf"
let outputURL = URL(fileURLWithPath: outputPath)

let pageWidth: CGFloat = 595
let pageHeight: CGFloat = 842
let margin: CGFloat = 38
let contentWidth = pageWidth - (margin * 2)

let titleColor = NSColor(calibratedRed: 0.10, green: 0.20, blue: 0.36, alpha: 1.0)
let accentColor = NSColor(calibratedRed: 0.20, green: 0.45, blue: 0.77, alpha: 1.0)
let bodyColor = NSColor(calibratedWhite: 0.16, alpha: 1.0)
let mutedColor = NSColor(calibratedWhite: 0.45, alpha: 1.0)
let pageBackground = NSColor(calibratedRed: 0.97, green: 0.98, blue: 1.0, alpha: 1.0)

let titleFont = NSFont.systemFont(ofSize: 21, weight: .bold)
let subtitleFont = NSFont.systemFont(ofSize: 9.8, weight: .medium)
let sectionTitleFont = NSFont.systemFont(ofSize: 10.8, weight: .bold)
let bodyFont = NSFont.systemFont(ofSize: 9.5, weight: .regular)
let footerFont = NSFont.systemFont(ofSize: 8.2, weight: .regular)

func paragraphStyle(lineSpacing: CGFloat = 1.6, paragraphSpacing: CGFloat = 3.0) -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.lineSpacing = lineSpacing
    style.paragraphSpacing = paragraphSpacing
    return style
}

func attrs(font: NSFont, color: NSColor, lineSpacing: CGFloat = 1.6, paragraphSpacing: CGFloat = 3.0) -> [NSAttributedString.Key: Any] {
    [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle(lineSpacing: lineSpacing, paragraphSpacing: paragraphSpacing)
    ]
}

func measuredHeight(for text: String, width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let rect = attributed.boundingRect(
        with: NSSize(width: width, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    return ceil(rect.height)
}

@discardableResult
func drawText(_ text: String, x: CGFloat, y: CGFloat, width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let height = measuredHeight(for: text, width: width, attributes: attributes)
    attributed.draw(with: NSRect(x: x, y: y, width: width, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading])
    return height
}

func drawRoundedRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil) {
    let path = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: width, height: height), xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = 1
        path.stroke()
    }
}

let sections: [Section] = [
    Section(
        title: "WHAT IT IS",
        body: "AppruvQR is a SwiftUI iOS accountability app for task tracking. Repo evidence shows a local-first flow where one user manages tasks, can require reviewer approval through short-lived signed QR codes, and keeps a streak tied to completion and sharing activity.",
        fillColor: NSColor(calibratedRed: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
    ),
    Section(
        title: "WHO IT'S FOR",
        body: "Primary persona (inferred from code): one user who wants help staying accountable for daily tasks and sometimes needs another person to review or approve work.",
        fillColor: NSColor(calibratedRed: 0.95, green: 0.98, blue: 0.94, alpha: 1.0)
    ),
    Section(
        title: "WHAT IT DOES",
        body: "- Create, edit, delete, pin, and date tasks with notes.\n- Filter tasks into Primary, All Task, Completed, and Missed views.\n- Group tasks by date and auto-mark overdue todo items as missed.\n- Support report tasks that require a selected reviewer before save.\n- Generate a signed profile QR code that refreshes every 10 seconds.\n- Scan reviewer QR codes to add reviewer contacts and approve protected tasks.\n- Track streaks, share progress, log notifications, and recover a lost streak through reflection sharing.",
        fillColor: NSColor(calibratedRed: 1.0, green: 0.98, blue: 0.92, alpha: 1.0)
    ),
    Section(
        title: "HOW IT WORKS",
        body: "- AppruvQRApp launches HomeView and registers one SwiftData container for TaskModel, UserModel, ReviewerModel, and NotificationModel.\n- SwiftUI views handle home, profile, streak, notification, reflection, task-sheet, QR, and scanner flows.\n- Data stays on-device in SwiftData; NotificationCenterStore writes local records for due-today, completed, progress-shared, reflection-shared, and streak events.\n- Flow: profile QR emits user_id, name, timestamp, and signature -> scanner validates timestamp and HMAC -> reviewer is added or matched -> task completion/share updates streak state and notifications.\n- Backend/API service: Not found in repo.",
        fillColor: NSColor(calibratedRed: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
    ),
    Section(
        title: "HOW TO RUN",
        body: "1. Open AppruvQR.xcodeproj in Xcode.\n2. Select the AppruvQR scheme and an iPhone or iPad simulator/device.\n3. Build and Run; the app starts at HomeView and uses generated Info.plist settings plus local SwiftData storage.\n4. Extra setup docs, automated tests, and backend configuration: Not found in repo.",
        fillColor: NSColor(calibratedRed: 0.94, green: 0.97, blue: 0.99, alpha: 1.0)
    )
]

var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
guard let consumer = CGDataConsumer(url: outputURL as CFURL),
      let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
    fputs("Failed to create PDF context at \(outputPath)\n", stderr)
    exit(1)
}

context.beginPDFPage(nil)
context.saveGState()
context.translateBy(x: 0, y: pageHeight)
context.scaleBy(x: 1, y: -1)

let graphicsContext = NSGraphicsContext(cgContext: context, flipped: true)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphicsContext

pageBackground.setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: pageWidth, height: pageHeight)).fill()

let headerHeight: CGFloat = 78
drawRoundedRect(
    x: margin,
    y: margin,
    width: contentWidth,
    height: headerHeight,
    radius: 18,
    fill: NSColor.white,
    stroke: NSColor(calibratedWhite: 0.86, alpha: 1.0)
)

let accentBarHeight: CGFloat = 9
drawRoundedRect(
    x: margin,
    y: margin,
    width: contentWidth,
    height: accentBarHeight,
    radius: 18,
    fill: accentColor
)

_ = drawText(
    "AppruvQR App Summary",
    x: margin + 18,
    y: margin + 21,
    width: contentWidth - 36,
    attributes: attrs(font: titleFont, color: titleColor, lineSpacing: 1.0, paragraphSpacing: 0)
)

_ = drawText(
    "One-page summary generated from repo evidence only.",
    x: margin + 18,
    y: margin + 47,
    width: contentWidth - 36,
    attributes: attrs(font: subtitleFont, color: mutedColor, lineSpacing: 1.0, paragraphSpacing: 0)
)

var currentY = margin + headerHeight + 11
let sectionSpacing: CGFloat = 7
let innerPadding: CGFloat = 12
let titleBottomGap: CGFloat = 5

for section in sections {
    let titleHeight = measuredHeight(
        for: section.title,
        width: contentWidth - (innerPadding * 2),
        attributes: attrs(font: sectionTitleFont, color: titleColor, lineSpacing: 1.0, paragraphSpacing: 0)
    )
    let bodyHeight = measuredHeight(
        for: section.body,
        width: contentWidth - (innerPadding * 2),
        attributes: attrs(font: bodyFont, color: bodyColor)
    )
    let boxHeight = innerPadding + titleHeight + titleBottomGap + bodyHeight + innerPadding

    drawRoundedRect(
        x: margin,
        y: currentY,
        width: contentWidth,
        height: boxHeight,
        radius: 16,
        fill: section.fillColor,
        stroke: NSColor(calibratedWhite: 0.88, alpha: 1.0)
    )

    _ = drawText(
        section.title,
        x: margin + innerPadding,
        y: currentY + innerPadding,
        width: contentWidth - (innerPadding * 2),
        attributes: attrs(font: sectionTitleFont, color: titleColor, lineSpacing: 1.0, paragraphSpacing: 0)
    )

    _ = drawText(
        section.body,
        x: margin + innerPadding,
        y: currentY + innerPadding + titleHeight + titleBottomGap,
        width: contentWidth - (innerPadding * 2),
        attributes: attrs(font: bodyFont, color: bodyColor)
    )

    currentY += boxHeight + sectionSpacing
}

let footerText = "Evidence sources in repo: SwiftUI views, SwiftData models, QR/scanner components, and Xcode project settings. README/setup guide: Not found in repo."
let footerHeight = measuredHeight(
    for: footerText,
    width: contentWidth,
    attributes: attrs(font: footerFont, color: mutedColor, lineSpacing: 1.2, paragraphSpacing: 0)
)
_ = drawText(
    footerText,
    x: margin,
    y: pageHeight - margin - footerHeight,
    width: contentWidth,
    attributes: attrs(font: footerFont, color: mutedColor, lineSpacing: 1.2, paragraphSpacing: 0)
)

let usedHeight = currentY + footerHeight
let availableHeight = pageHeight - margin
if usedHeight > availableHeight {
    fputs("Layout overflow detected: used \(usedHeight), available \(availableHeight)\n", stderr)
    exit(2)
}

NSGraphicsContext.restoreGraphicsState()
context.restoreGState()
context.endPDFPage()
context.closePDF()

print(outputPath)
