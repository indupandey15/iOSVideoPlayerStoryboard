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
    private let videoViewModel = VideoViewModel()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call a method to make buttons circular
        makeButtonsCircular()
        
        // Set up navigation bar
        setupNavigationBar()
        
        // Do any additional setup after loading the view.
        videoViewModel.fetchVideos {
            self.updateUI()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        // Implement next video functionality
        // Check if there is a video at the next index
        guard currentVideoIndex < videoViewModel.videos.count - 1 else { return }
        
        // Increment the current video index
        currentVideoIndex += 1
        
        // Update the UI to display the new video
        updateUI()
        
    }
    
    @IBAction private func previousButtonTapped(_ sender: UIButton) {
        // Implement previous video functionality
        // Check if there is a video at the previous index
        guard currentVideoIndex > 0 else { return }
        
        // Decrement the current video index
        currentVideoIndex -= 1
        
        // Update the UI to display the new video
        updateUI()
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        // Implement play/pause video functionality
        onTapPlayPause()
    }
    
    
    // MARK: - UI Setup and Update Methods
    private func setupNavigationBar() {
        // Customize the title's attributes
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Chalkduster", size: 24.0) ?? UIFont.systemFont(ofSize: 24.0),
            .foregroundColor: UIColor.black // Set the desired text color
        ]
        self.navigationController?.navigationBar.titleTextAttributes = fontAttributes
    }
    
    func updateUI() {
        guard videoViewModel.videos.indices.contains(currentVideoIndex) else { return }
        
        let currentVideo = videoViewModel.videos[currentVideoIndex]
        self.videoURL = currentVideo.fullURL
        
        // Display title, author, and description in the detailTextView
        let detailsText = "Title: \(currentVideo.title)\n\nAuthor: \(currentVideo.author.name)\n\nDescription: \(currentVideo.description)"
        self.detailTextView.text = detailsText
        
        self.setVideoPlayer()
        self.scribingAndPositioning(show: false)
    }
    
    private func makeButtonsCircular() {
        // Loop through the arranged subviews of stackCtrView
        for case let button as UIButton in stackCtrView.arrangedSubviews {
            // Set corner radius to make the button circular
            button.layer.cornerRadius = button.frame.size.width / 2
            button.clipsToBounds = true
        }
    }
    
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
        // Toggle play/pause on button tap
        if self.player?.timeControlStatus == .playing {
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            self.player?.pause()
        } else {
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
            self.player?.play()
        }
    }
    
    func onSlideSeekSlider() {
        // Add target for seek slider value change
        self.seekSlider.addTarget(self, action: #selector(onTapToSlide), for: .valueChanged)
    }
    
    func onTapFullScreen() {
        // Add tap gesture recognizer for full-screen toggle
        self.imgFullScreenToggle.isUserInteractionEnabled = true
        self.imgFullScreenToggle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapToggleScreen)))
    }
    
    
    
    // MARK: - Orientation Handling
    private var windowInterface : UIInterfaceOrientation? {
        return self.view.window?.windowScene?.interfaceOrientation
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        // Adjust video player height and update frame on orientation change
        
        // Call the superclass implementation
        super.willTransition(to: newCollection, with: coordinator)
        
        // Check if the window interface is available
        guard let windowInterface = self.windowInterface else { return }
        
        // Determine if the device is in portrait or landscape orientation
        if windowInterface.isPortrait ==  true {
            // Set the video player height to 300 in portrait mode
            self.videoPlayerHeight.constant = 300
        } else {
            // Set the video player height to the width of the view in landscape mode
            self.videoPlayerHeight.constant = self.view.layer.bounds.width
        }
        
        // Print the updated video player height for debugging purposes
        print(self.videoPlayerHeight.constant)
        
        // Delay the execution of the following code for a short duration (0.1 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            // Update the frame of the player layer to match the video player bounds
            self.playerLayer?.frame = self.videoPlayer.bounds
        })
    }
    
    
    // MARK: - Utility Methods
    
    private func scribingAndPositioning(show : Bool) {
        // Calculate and display position of thumb along with slider
        let trackRec = self.seekSlider.trackRect(forBounds: self.seekSlider.bounds)
        let thumbRect = self.seekSlider.thumbRect(forBounds: self.seekSlider.bounds, trackRect: trackRec, value: self.seekSlider.value)
        // Only when displaying thumbnail along with slider
        if show == true {
            let _ = thumbRect.origin.x + self.seekSlider.frame.origin.x
            let _ = self.seekSlider.frame.origin.y - 45
        }
    }
    
    private func setObserverToPlayer() {
        // Set periodic time observer to update player time
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
        // Set flag indicating user is actively seeking
        self.isThumbSeek = true
        
        // Check if the slider is actively being tracked by the user
        if self.seekSlider.isTracking == true {
            // If tracking, display thumb position along with slider
            self.scribingAndPositioning(show: true)
        } else {
            // If not tracking, perform seek based on slider value
            guard let duration = self.player?.currentItem?.duration else { return }
            let value = Float64(self.seekSlider.value) * CMTimeGetSeconds(duration)
            
            // Ensure seek value is not NaN
            if value.isNaN == false {
                // Create a CMTime object representing the seek time
                let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
                
                // Seek to the calculated time and handle completion
                self.player?.seek(to: seekTime, completionHandler: { completed in
                    if completed {
                        // Reset seeking flag and hide thumb position display
                        self.isThumbSeek = false
                        self.scribingAndPositioning(show: false)
                    }
                })
            }
        }
    }
    
    
    // MARK: - Additional Methods
    
    @objc private func onTap10SecNext() {
        // Get the current time of the video
        guard let currentTime = self.player?.currentTime() else { return }
        
        // Calculate the seek time 10 seconds ahead
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: 10)
        
        // Create a CMTime object representing the seek time
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        
        // Seek to the calculated time (10 seconds ahead) without completion handler
        self.player?.seek(to: seekTime, completionHandler: { completed in
            // Optional: Handle completion if needed
        })
    }
    
    @objc private func onTap10SecBack() {
        // Get the current time of the video
        guard let currentTime = self.player?.currentTime() else { return }
        
        // Calculate the seek time 10 seconds back
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: -10)
        
        // Create a CMTime object representing the seek time
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        
        // Seek to the calculated time (10 seconds back) without completion handler
        self.player?.seek(to: seekTime, completionHandler: { completed in
            // Optional: Handle completion if needed
        })
    }
    
    @objc private func onTapToggleScreen() {
        // Check if iOS 16.0 is available (with new API for interface orientation)
        if #available(iOS 16.0, *) {
            // Get the window scene associated with the view
            guard let windowScene = self.view.window?.windowScene else { return }
            
            // Check the current interface orientation of the window scene
            if windowScene.interfaceOrientation == .portrait {
                // Request a geometry update for landscape orientation
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
                    // Handle errors if needed
                    print(error.localizedDescription)
                }
            } else {
                // Request a geometry update for portrait orientation
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                    // Handle errors if needed
                    print(error.localizedDescription)
                }
            }
        } else {
            // For iOS versions prior to 16.0, manually toggle the device orientation
            if UIDevice.current.orientation == .portrait {
                // Set the device orientation to landscape right
                let orientation = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            } else {
                // Set the device orientation to portrait
                let orientation = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            }
        }
    }
    
}
