/*
Copyright (C) 2016 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Constants used between the Potloc target and the Potloc WatchKit Extension target.

        The constants found in this file are used as keys and values in the dictionaries
        sent when using the WatchConnectivity methods to send and receive messages.
*/

/// Keys used by the dictionaries when communicating between the watch and the phone.
enum MessageKey: String {
    case command
    case stateUpdate
    case acknowledge = "ack"
    case locationCount
}

/// Used by the dicationaries when communicating between the watch and the phone.
enum MessageCommand: String {
    case sendLocationStatus
    case startUpdatingLocation
    case stopUpdatingLocation
}
