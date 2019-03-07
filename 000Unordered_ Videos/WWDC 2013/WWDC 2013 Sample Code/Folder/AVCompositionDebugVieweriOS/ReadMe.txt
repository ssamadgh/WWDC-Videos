AVCompositionDebugVieweriOS

This sample application has an AVCompositionDebugView which presents a visual description of the underlying AVComposition, AVVideoComposition and AVAudioMix objects which form the composition made using two clips, adding a cross fade transition in between and audio ramps to the two audio tracks.

The main files are as follows:

APLViewController.m/.h:
The view controller setups playback of AVMutableComposition and also initializes an APLCompositionDebugView which then represents the underlying composition, video composition and audio mix. It also handles play/pause and scrubbing utilities.

APLSimpleEditor.m/.h:
Simple editor setups an AVMutableComposition using supplied clips and time ranges. It also setups AVVideoComposition to add a crossfade transition.

AVCompositionDebugView.m/.h:
 A subclass of UIView that represents the composition, video composition and audio mix objects in a diagram. It also contains a time marker layer which is synchronized to the current player item using AVSynchronizedLayer, to track the currentTime of a player.

main.m:
Standard main file.

========================================================================
Copyright © 2013 Apple Inc. All rights reserved.