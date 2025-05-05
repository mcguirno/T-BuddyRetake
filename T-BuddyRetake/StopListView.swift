//
//  ContentView.swift
//  T-BuddyRetake
//
//  Created by Noah McGuire on 5/5/25.
//

import SwiftUI
import SwiftData

struct StopListView: View {
    enum MBTASubwayLine: String, CaseIterable {
        case redLine = "Red"
        case orangeLine = "Orange"
        case blueLine = "Blue"
        case greenLineB = "Green-B"
        case greenLineC = "Green-C"
        case greenLineD = "Green-D"
        case greenLineE = "Green-E"
        case silverLine1 = "SL1"
        case silverLine2 = "SL2"
        case silverLine3 = "SL3"
        case silverLine4 = "SL4"
        case silverLine5 = "SL5"
        
        var color: Color {
            switch self {
            case .redLine: return .red
            case .orangeLine: return .orange
            case .blueLine: return .blue
            case .greenLineB, .greenLineC, .greenLineD, .greenLineE: return .green
            case .silverLine1, .silverLine2, .silverLine3, .silverLine4, .silverLine5: return .gray
            }
        }
        
        var urlEnding: String {
            switch self {
            case .silverLine1: return "741"
            case .silverLine2: return "742"
            case .silverLine3: return "743"
            case .silverLine4: return "749"
            case .silverLine5: return "751"
            default: return self.rawValue
            }
        }
    }
    @Query var userSettings: [UserSetting]
    @State private var selectedLine: MBTASubwayLine = .greenLineD
    @State private var stopVM = StopViewModel()
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        NavigationStack {
            ZStack {
                selectedLine.color
                    .ignoresSafeArea()
                VStack (alignment: .leading) {
                    List {
                        ForEach(stopVM.stops) { stop in
                            VStack(alignment: .leading) {
                                Text(stop.attributes.name)
                                    .font(.title)
                                Text(stop.attributes.address ?? "")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    HStack {
                        Text("Choose a Line:")
                            .bold()
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("", selection: $selectedLine) {
                            ForEach(MBTASubwayLine.allCases, id: \.self) { line in
                                Text(line.rawValue)
                            }
                        }
                        .tint(.white)
                        .onChange(of: selectedLine) {
                            Task {
                                userSettings.forEach { modelContext.delete($0)
                                }
                                var userSettings = UserSetting(preferredLine: selectedLine.rawValue)
                                modelContext.insert(userSettings)
                                guard let _ = try? modelContext.save() else {
                                    print("ERROR: modelContext.save didn't work")
                                    return
                                }
                                await stopVM.getData(urlEnding: selectedLine.urlEnding)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .font(.title2)
                }
            }
            .listStyle(.plain)
            .navigationTitle("\(selectedLine.rawValue) Stops")
            .toolbarBackground(selectedLine.color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if let savedSetting = userSettings.first?.preferredLine {
                switch savedSetting {
                case "Red": selectedLine = .redLine
                case "Orange": selectedLine = .orangeLine
                case "Blue": selectedLine = .blueLine
                case "Green-B": selectedLine = .greenLineB
                case "Green-C": selectedLine = .greenLineC
                case "Green-D": selectedLine = .greenLineD
                case "Green-E": selectedLine = .greenLineE
                case "SL1": selectedLine = .silverLine1
                case "SL2": selectedLine = .silverLine2
                case "SL3": selectedLine = .silverLine3
                case "SL4": selectedLine = .silverLine4
                case "SL5": selectedLine = .silverLine5
                default: selectedLine = .greenLineD
                }
            }
            await stopVM.getData(urlEnding: selectedLine.urlEnding)
        }
    }
}

#Preview {
    StopListView()
}
