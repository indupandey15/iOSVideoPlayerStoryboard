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

    func fetchVideos(completion: @escaping () -> Void) {
        let apiURL = "http://localhost:4000/videos"

        AF.request(apiURL).responseDecodable(of: [Video].self) { response in
            switch response.result {
            case .success(let videos):
                self.videos = videos.sorted { $0.publishedAt > $1.publishedAt }
                completion()

            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
