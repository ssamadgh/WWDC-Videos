
SloPoke

SloPoke illustrates best practices for capturing high frame-rate content using the AVCaptureDevice, AVCaptureSession, and AVCaptureMovieFileOutput classes.

Captured content can then be played back at various rates, with and without pitch shifting, using the AVPlayer, AVPlayerItem, and AVAsset classes.
In the PlayerView, you can manipulate playback using a variety of gestures:
	Touch once to toggle play / pause.
	Swipe left or right while playing to increase or decrease the playback rate between .25 and 2.0x.
	Swipe left or right while paused to step one frame forward or backward.
	Swipe down to begin a scaled edit.
	Swipe up to end a scaled edit, at which time a dialog appears, allowing you to choose a playback rate for the edited section.
Scaled duration edits are implemented using the AVMutableComposition class.

===========================================================================
Copyright (C) 2013 Apple Inc. All rights reserved.
