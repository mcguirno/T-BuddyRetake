//
//  StopViewModel.swift
//  T-BuddyRetake
//
//  Created by Noah McGuire on 5/5/25.
//

import Foundation

@Observable
class StopViewModel {
    struct Response: Codable {
        var data: [Stop]
    }
    struct Stop: Codable, Identifiable {
        var attributes: StopInfo
        var id: String
    }
    var stops: [Stop] = []
    var urlString = "https://api-v3.mbta.com/stops?filter%5Broute%5D="
    func getData(urlEnding: String) async {
        print("We are accessing the url \(urlString+urlEnding)")
        guard let url = URL(string: urlString+urlEnding) else {
            print("ERROR: could not turn \(urlString+urlEnding) into a valid url")
            return
        }
        do {
            let configuration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configuration)
            let (data, _) = try await session.data(from: url)
            guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
                print("JSON ERROR: Could not decode returned JSON Data from \(urlString+urlEnding)")
                return
            }
            print("JSON Returned! We have just return \(response.data.count) stops")
            Task { @MainActor in
                self.stops = response.data
            }
        } catch {
            print("Error: Could not get data from \(urlString+urlEnding). \(error.localizedDescription)")
        }
    }
}
