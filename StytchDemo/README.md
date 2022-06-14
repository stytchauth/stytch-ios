# StytchDemo
This repo includes small demo applications for both iOS and macOS so you can test out what it would be like to use Stytch in your own apps. The sample apps show a very basic logged-out experience, a small logged-in flow, and some example interaction with a demo server (via managing a list of hobbies) to mimic authenticated calls to your server.
## Running the demo
To run the demo, do the following:
1. Open a terminal window to the project's root directory
1. Run `make demo`. This will prompt you for any required configuration (first run only) and will start the local server
1. Build and run one or both of the demo applications from Xcode
1. (Optional) If you'd like to debug any calls to the server, you can use Xcode's `Debug > Attach to Process > Likely Targets > StytchDemo (Server)`
