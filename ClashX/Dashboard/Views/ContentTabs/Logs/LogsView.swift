//
//  LogsView.swift
//  ClashX Dashboard
//
//

import SwiftUI

struct LogsView: View {
	
	@EnvironmentObject var logStorage: ClashLogStorage
	
	@State var searchString: String = ""
	@State var logLevel = ConfigManager.selectLoggingApiLevel
	
    var body: some View {
		Group {
			LogsTableView(data: logStorage.logs.reversed(), filterString: searchString)
		}
		.onAppear {
			guard let s = ToolbarStore.shared.searchStrings["logs"] else { return }
			searchString = s
			NotificationCenter.default.post(name: .initSearchString, object: nil, userInfo: ["string": s])
		}
		.onDisappear {
			ToolbarStore.shared.searchStrings["logs"] = searchString
		}
		.onReceive(NotificationCenter.default.publisher(for: .toolbarSearchString)) {
			guard let string = $0.userInfo?["String"] as? String else { return }
			searchString = string
		}
		.onReceive(NotificationCenter.default.publisher(for: .logLevelChanged)) {
			guard let level = $0.userInfo?["level"] as? ClashLogLevel else { return }
			logLevelChanged(level)
		}
    }
	
	func logLevelChanged(_ level: ClashLogLevel) {
		logStorage.logs.removeAll()
		ConfigManager.selectLoggingApiLevel = level
		ApiRequest.shared.resetLogStreamApi()
	}
}

struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        LogsView()
    }
}