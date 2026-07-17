import UIKit
import SwiftUI
import Darwin

// MARK: - Device System Info

struct SystemInfo {
    static var deviceName: String { UIDevice.current.name }
    static var deviceModel: String { UIDevice.current.model }
    static var systemName: String { UIDevice.current.systemName }
    static var systemVersion: String { UIDevice.current.systemVersion }
    static var identifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.compactMap { $0.value as? Int8 }.map { String(UnicodeScalar(UInt8($0))) }.joined().trimmingCharacters(in: .controlCharacters)
    }
    static var displayName: String {
        let id = identifier
        let map: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro", "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini", "iPhone14,5": "iPhone 13",
            "iPhone14,7": "iPhone 14", "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro", "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15", "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 16 Pro", "iPhone16,2": "iPhone 16 Pro Max",
            "iPhone16,3": "iPhone 16", "iPhone16,4": "iPhone 16 Plus",
            "iPhone17,1": "iPhone 17 Pro", "iPhone17,2": "iPhone 17 Pro Max",
            "iPhone17,3": "iPhone 17", "iPhone17,4": "iPhone 17 Plus",
        ]
        return map[id] ?? id
    }

    static var cpuArch: String {
        var cpuinfo: [CInt] = [0, 0, 0, 0]
        var size = MemoryLayout<CInt>.size * 4
        sysctlbyname("hw.cpu64bit_capable", &cpuinfo, &size, nil, 0)
        return "ARM64"
    }

    static var cpuCount: Int { ProcessInfo.processInfo.processorCount }
    static var cpuActive: Int { ProcessInfo.processInfo.activeProcessorCount }

    static var physicalMemory: String {
        let mem = ProcessInfo.processInfo.physicalMemory
        return String(format: "%.1f GB", Double(mem) / 1_073_741_824)
    }

    static var screenResolution: String {
        let s = UIScreen.main.nativeBounds
        return "\(Int(s.width))×\(Int(s.height))"
    }

    static var screenScale: String {
        "\(Int(UIScreen.main.scale))x"
    }

    static var refreshRate: Double {
        if #available(iOS 15.0, *) {
            let maxFps = UIScreen.main.maximumFramesPerSecond
            return Double(maxFps)
        }
        return 60
    }

    static var isHighRefreshRate: Bool { refreshRate > 60 }

    static var batteryLevel: Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level < 0 ? -1 : Int(level * 100)
    }

    static var batteryState: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .charging: return "Đang sạc"
        case .full: return "Đầy"
        case .unplugged: return "Pin"
        default: return "Không xác định"
        }
    }

    static var diskFree: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: path) {
            let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
            return String(format: "%.1f GB", Double(free) / 1_073_741_824)
        }
        return "N/A"
    }

    static var diskTotal: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: path) {
            let total = (attrs[.systemSize] as? NSNumber)?.int64Value ?? 0
            return String(format: "%.1f GB", Double(total) / 1_073_741_824)
        }
        return "N/A"
    }

    static var networkType: String {
        // Simplified: always show WiFi
        return "WiFi / 5G"
    }

    static var currentIP: String {
        "192.168.x.x"
    }
}

// MARK: - Performance Monitor

final class PerformanceMonitor: ObservableObject {
    @Published var fps: Double = 0
    @Published var cpuUsage: Double = 0
    @Published var memoryUsed: String = "0 MB"

    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.calculateStats()
        }
    }

    private func calculateStats() {
        fps = 60.0

        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            let used = Double(info.resident_size) / 1_073_741_824
            memoryUsed = String(format: "%.1f GB", used)
        }

        let total = ProcessInfo.processInfo.physicalMemory
        cpuUsage = Double(info.resident_size) / Double(total) * 100
    }

    func cleanup() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        cleanup()
    }
}
