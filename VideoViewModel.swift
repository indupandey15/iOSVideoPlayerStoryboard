//
//  VideoViewModel.swift
//  iOSVideoPlayerStoryboard
//
//  Created by Indu Pandey on 16/01/24.
//

import Foundation
import Alamofire

class VideoViewModel {
    var videos: [Video] = []

    // Fetch videos from the API
    func fetchVideos(completion: @escaping () -> Void) {
        let apiURL = "http://localhost:4000/videos"

        AF.request(apiURL).responseDecodable(of: [Video].self) { response in
            switch response.result {
            case .success(let videos):
                // Sort videos by published date in descending order
                self.videos = videos.sorted { $0.publishedAt > $1.publishedAt }
                
                // Notify the completion handler that fetching is complete
                completion()

            case .failure(let error):
                // Handle API request failure
                print("Request failed with error: \(error)")
            }
        }
    }
}
