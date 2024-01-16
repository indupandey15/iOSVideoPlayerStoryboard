//
//  ViewController.swift
//  iOSVideoPlayerStoryboard
//
//  Created by Indu Pandey on 16/01/24.
//

import UIKit
import AVKit


class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var videoPlayerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewControll: UIView!
    @IBOutlet weak var stackCtrView: UIStackView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var lbCurrentTime: UILabel!
    @IBOutlet weak var lbTotalTime: UILabel!
    @IBOutlet weak var seekSlider: UISlider! {
        didSet {
            onSlideSeekSlider()
        }
    }
    @IBOutlet weak var imgFullScreenToggle: UIImageView! {
        didSet {
            onTapFullScreen()
        }
    }
    
    // MARK: - Properties
    
    private var currentVideoIndex = 0
    private var isThumbSeek : Bool = false
    private var player : AVPlayer? = nil
    private var playerLayer : AVPlayerLayer? = nil
    var videoURL = String()
    private var timeObserver : Any? = nil
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        // Implement next video functionality
       
    }
    
    @IBAction private func previousButtonTapped(_ sender: UIButton) {
        // Implement previous video functionality
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        // Implement play/pause video functionality
    }
    
    
    // MARK: - UI Setup and Update Methods
    
    private func setVideoPlayer() {
        guard let url = URL(string: videoURL) else { return }

        // Pause and deallocate the existing player and playerLayer
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil

        // Create a new AVPlayer and AVPlayerLayer
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = videoPlayer.bounds

        // Add the new playerLayer to the videoPlayer view
        if let playerLayer = playerLayer {
            self.videoPlayer.layer.addSublayer(playerLayer)
        }

        // Play the new video
        player?.play()

        // Set up observers for the new player
        setObserverToPlayer()
    }
    
    // MARK: - Gesture Recognizer Actions
    
    @objc private func onTapPlayPause() {
        if self.player?.timeControlStatus == .playing {
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            self.player?.pause()
        } else {
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
            self.player?.play()
        }
    }
    
    func onSlideSeekSlider() {
        self.seekSlider.addTarget(self, action: #selector(onTapToSlide), for: .valueChanged)
    }
    
    func onTapFullScreen() {
        self.imgFullScreenToggle.isUserInteractionEnabled = true
        self.imgFullScreenToggle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapToggleScreen)))
    }

   

    // MARK: - Orientation Handling
    private var windowInterface : UIInterfaceOrientation? {
        return self.view.window?.windowScene?.interfaceOrientation
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        guard let windowInterface = self.windowInterface else { return }
        if windowInterface.isPortrait ==  true {
            self.videoPlayerHeight.constant = 300
        } else {
            self.videoPlayerHeight.constant = self.view.layer.bounds.width
        }
        print(self.videoPlayerHeight.constant)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.playerLayer?.frame = self.videoPlayer.bounds
        })
    }
    
    // MARK: - Utility Methods
    
    private func scribingAndPositioning(show : Bool) {
        let trackRec = self.seekSlider.trackRect(forBounds: self.seekSlider.bounds)
        let thumbRect = self.seekSlider.thumbRect(forBounds: self.seekSlider.bounds, trackRect: trackRec, value: self.seekSlider.value)
        if show == true {
            let x = thumbRect.origin.x + self.seekSlider.frame.origin.x
            let y = self.seekSlider.frame.origin.y - 45
        }
    }
    
    private func setObserverToPlayer() {
        let interval = CMTime(seconds: 0.3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsed in
            self.updatePlayerTime()
        })
    }
    
    private func updatePlayerTime() {
        // Ensure there is a valid current time and duration
        guard let currentTime = self.player?.currentTime(), let duration = self.player?.currentItem?.duration else { return }
        
        // Calculate current and total duration in seconds
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        let durationTimeInSeconds = CMTimeGetSeconds(duration)
        
        // Update seek slider value if not actively seeking
        if !self.isThumbSeek {
            self.seekSlider.value = Float(currentTimeInSeconds / durationTimeInSeconds)
        }
        
        // Update current time label with formatted string
        self.lbCurrentTime.text = formattedTimeString(seconds: currentTimeInSeconds)
        
        // Update total time label with formatted string
        self.lbTotalTime.text = formattedTimeString(seconds: durationTimeInSeconds)
    }

    // Helper method to format seconds into HH:mm:ss string
    private func formattedTimeString(seconds: Double) -> String {
        // Calculate hours, minutes, and seconds
        let hours = seconds / 3600
        let mins = (seconds / 60).truncatingRemainder(dividingBy: 60)
        let secs = seconds.truncatingRemainder(dividingBy: 60)
        
        // Number formatter for consistent formatting
        let timeFormatter = NumberFormatter()
        timeFormatter.minimumIntegerDigits = 2
        timeFormatter.minimumFractionDigits = 0
        timeFormatter.roundingMode = .down
        
        // Convert components to formatted strings
        guard let hoursStr = timeFormatter.string(from: NSNumber(value: hours)),
              let minsStr = timeFormatter.string(from: NSNumber(value: mins)),
              let secsStr = timeFormatter.string(from: NSNumber(value: secs)) else {
            return ""
        }
        
        // Combine components into HH:mm:ss format
        return "\(hoursStr):\(minsStr):\(secsStr)"
    }


    
    @objc private func onTapToSlide() {
        self.isThumbSeek = true
        if self.seekSlider.isTracking == true {
            self.scribingAndPositioning(show: true)
        } else {
            guard let duration = self.player?.currentItem?.duration else { return }
            let value = Float64(self.seekSlider.value) * CMTimeGetSeconds(duration)
            if value.isNaN == false {
                let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
                self.player?.seek(to: seekTime, completionHandler: { completed in
                    if completed {
                        self.isThumbSeek = false
                        self.scribingAndPositioning(show: false)
                    }
                })
            }
        }
    }
    
    
    @objc private func onTap10SecNext() {
        guard let currentTime = self.player?.currentTime() else { return }
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: 10)
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        self.player?.seek(to: seekTime, completionHandler: { completed in
            
        })
    }
    
    @objc private func onTap10SecBack() {
        guard let currentTime = self.player?.currentTime() else { return }
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: -10)
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        self.player?.seek(to: seekTime, completionHandler: { completed in
            
        })
    }
    
    
    @objc private func onTapToggleScreen() {
        if #available(iOS 16.0, *) {
            guard let windowSceen = self.view.window?.windowScene else { return }
            if windowSceen.interfaceOrientation == .portrait {
                windowSceen.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
                    print(error.localizedDescription)
                }
            } else {
                windowSceen.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                    print(error.localizedDescription)
                }
            }
        } else {
            if UIDevice.current.orientation == .portrait {
                let orientation = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            } else {
                let orientation = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            }
        }
    }

}

