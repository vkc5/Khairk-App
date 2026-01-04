import UIKit

final class LogsExportPresenter {

    static func presentExportPopup(from viewController: UIViewController, logs: [SystemLog]) {
        let popup = LogsExportPopupViewController(
            title: "Export Data to Excel",
            message: "Do you want to export the current log data as an Excel (.csv) file?",
            state: .confirm,
            primaryTitle: "Export",
            secondaryTitle: "Cancel",
            onPrimary: {
                handleExport(from: viewController, logs: logs)
            },
            onSecondary: {}
        )
        viewController.present(popup, animated: true)
    }

    private static func handleExport(from viewController: UIViewController, logs: [SystemLog]) {
        switch LogsExportService.exportCSV(logs: logs) {
        case .success(let url):
            let success = LogsExportPopupViewController(
                title: "Export Successful",
                message: "Your Excel file has been downloaded successfully.",
                state: .success,
                primaryTitle: "Done",
                secondaryTitle: "View File",
                onPrimary: {},
                onSecondary: {
                    presentShareSheet(from: viewController, fileURL: url)
                }
            )
            viewController.present(success, animated: true)
        case .failure:
            let failure = LogsExportPopupViewController(
                title: "Export Failed",
                message: "Something went wrong while exporting. Please try again later.",
                state: .failure,
                primaryTitle: "Retry",
                secondaryTitle: "Cancel",
                onPrimary: {
                    handleExport(from: viewController, logs: logs)
                },
                onSecondary: {}
            )
            viewController.present(failure, animated: true)
        }
    }

    private static func presentShareSheet(from viewController: UIViewController, fileURL: URL) {
        let activity = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let popover = activity.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 1,
                height: 1
            )
        }
        viewController.present(activity, animated: true)
    }
}
