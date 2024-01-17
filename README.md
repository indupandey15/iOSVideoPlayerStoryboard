# iOSVideoPlayerStoryboard
silverorange Native App Developer Assessment
============================================

This exercise is designed to assess how you approach tasks required in your position as a native app developer at silverorange. We are interested in how you work as much we're interested the final results, so please include useful Git commit messages and comments where you think your code may be unclear.

Wireframe
---------
![wireframe](docs/wireframe.png)

Tasks
-----
Using either one of the blank Android projects, **or** one of the blank iOS projects found in `/android` or `/ios`, complete the following:

 1. Display a screen similar to the provided wireframe. The screen should
    contain a video player at the top and a scrollable details section at the
    bottom.
 2. Import and use the provided image assets in `assets/` for the media
    controls. For Android, use the provided SVG files. For iOS, use the provided PDF files.
 3. Fetch a list of videos from the provided API (see instructions below for
    running the API).
 4. Sort the received list of videos by date.
 5. Load the first video into the UI by default.
 6. Implement the play/pause button for the video player. The app should be
    paused on startup.
 7. Implement next/previous buttons for the video player. Clicking next should
    update the UI with the next video and video details. Buttons should be
    insensitive when at the start/end of the list.
 8. In the details section, show the returned description for the current video
    as rendered Markdown.
 9. In the details section, also display the title and author of the current
    video.

Environment
-----------
For this project, you can use any one of:

 - Android
   - Kotlin or Java
   - XML layouts or Jetpack Compose
 - iOS
   - Swift
   - SwiftUI or Storyboards

There are blank projects in the `android/` and `ios/` folders which should suit whichever combination of language, platform, and UI toolkit you prefer to work with. Please start with one of these blank projects using Android Studio or Xcode.

Dependencies
------------
For media playback, Markdown parsing and/or networking you may want to use external dependencies. For Android, please use Gradle dependencies. For iOS, please use CocoaPods ([installation instructions](https://cocoapods.org/)).

You may consider using these packages, but are not required to use them:

iOS:
 - https://cocoapods.org/pods/MarkdownKit (Markdown)
 - https://cocoapods.org/pods/Down (Markdown)
 - https://cocoapods.org/pods/Alamofire (Networking)

Android: 
 - https://github.com/google/ExoPlayer#using-exoplayer (Media playback)
 - https://noties.io/Markwon/docs/v4/install.html (Markdown)
 - https://github.com/google/gson#download (JSON parsing)
 - https://square.github.io/okhttp/#releases (HTTP)
 - https://square.github.io/retrofit/#download (HTTP + parsing)

Commits
-------
Your commit history is important to us! Try to make meaningful commit messages that show your progress.

Getting Started With the Server Backend (/server)
-----------------------------------------------
For this exercise a pre-built server application is provided. The application runs by default on `localhost:4000` and has the following endpoints:

 - `http://localhost:4000/videos` - returns a JSON-encoded array of videos.

### Running the Server

The provided API server is needed as a data source for your project. To run the server you will need NodeJS and Yarn.

![](docs/apple.svg) On macOS you can install the requirements using Homebrew ([installation instructions](https://brew.sh/)) with:

```sh
brew install node yarn
```

![](docs/linux.svg) On Linux, use your distribution’s package manager to install Node JS and Yarn. Node 10 or greater is required. You may need to add repositories:

 - https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
 - https://classic.yarnpkg.com/en/docs/install/#debian-stable

![](docs/windows.svg) On Windows, the best option is to use package installers from:

 - https://nodejs.org/en/download/, and
 - https://classic.yarnpkg.com/en/docs/install/#windows-stable

With dependencies installed, you can run the server with:

```sh
cd server
yarn install
yarn start
```

You can verify the API is working by visiting http://localhost:4000/videos in your browser or another HTTP client.

