import Foundation

enum LogsExportError: Error {
    case emptyLogs
    case invalidMetadata
    case writeFailed
}

final class LogsExportService {

    static func exportCSV(logs: [SystemLog]) -> Result<URL, Error> {
        guard !logs.isEmpty else { return .failure(LogsExportError.emptyLogs) }

        let header = "timestamp,userName,userRole,type,action,description,severity,metadata"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let rows = logs.map { log -> String in
            let timestamp = formatter.string(from: log.timestamp)
            let metadataString = serializeMetadata(log.metadata)
            return [
                timestamp,
                log.userName,
                log.userRole,
                log.type,
                log.action,
                log.description,
                log.severity,
                metadataString,
            ].map { escapeCSV($0) }.joined(separator: ",")
        }

        let csv = ([header] + rows).joined(separator: "\n")
        let fileName = "SystemLogs_" + fileTimestamp() + ".csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return .success(fileURL)
        } catch {
            return .failure(LogsExportError.writeFailed)
        }
    }

    private static func serializeMetadata(_ metadata: [String: Any]) -> String {
        guard !metadata.isEmpty else { return "" }
        if JSONSerialization.isValidJSONObject(metadata),
           let data = try? JSONSerialization.data(withJSONObject: metadata, options: []),
           let text = String(data: data, encoding: .utf8) {
            return text
        }
        return String(describing: metadata)
    }

    private static func escapeCSV(_ value: String) -> String {
        // Quote to preserve commas, quotes, and newlines in Excel.
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private static func fileTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }
}
