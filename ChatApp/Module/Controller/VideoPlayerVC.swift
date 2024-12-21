//
//  VideoPlayerVC.swift
//  ChatApp
//
//  Created by Miguel Angel Gutierrez Maya on 6/11/24.
//

import Foundation
import AVKit

class VideoPlayerVC: AVPlayerViewController {
    private var videoURL: URL
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Video Player"
        view.backgroundColor = .systemGray6
        
        player = AVPlayer(url: videoURL)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            try? FileManager.default.removeItem(at: videoURL)
        }
    }
}
