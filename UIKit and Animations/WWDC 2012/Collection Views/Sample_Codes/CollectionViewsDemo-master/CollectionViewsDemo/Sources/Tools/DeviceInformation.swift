//
//  DeviceInformation.swift
//
//  Copyright © 2015 Sébastien MICHOY and contributors.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. Redistributions in binary
//  form must reproduce the above copyright notice, this list of conditions and
//  the following disclaimer in the documentation and/or other materials
//  provided with the distribution. Neither the name of the nor the names of
//  its contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

import UIKit

// MARK: Device Information

enum DeviceModel {
    case iPad2, iPad3, iPadMini, iPad4, iPadMini2, iPadAir, iPadMini3, iPadAir2
    case iPhone4, iPhone4S, iPhone5, iPhone5C, iPhone5S, iPhone6, iPhone6Plus
    case iPod5
    case simulator
    case unknown
}

func deviceOrientation() -> UIDeviceOrientation {
    return UIDevice.current.orientation
}

func deviceModel() -> DeviceModel {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let machine = systemInfo.machine
    let mirror = Mirror(reflecting: machine)
    var modelId = ""
    
    for child in mirror.children where child.value is Int8 && (child.value as! Int8) != 0 {
        let value = child.value as! Int8
        modelId.append(String(UnicodeScalar(UInt8(value))))
    }
    
    let deviceModel: DeviceModel
    
    switch modelId {
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
        deviceModel = .iPad2
    case "iPad3,1", "iPad3,2", "iPad3,3":
        deviceModel = .iPad3
    case "iPad2,5", "iPad2,6", "iPad2,7":
        deviceModel = .iPadMini
    case "iPad3,4", "iPad3,5", "iPad3,6":
        deviceModel = .iPad4
    case "iPad4,4", "iPad4,5", "iPad4,6":
        deviceModel = .iPadMini2
    case "iPad4,1", "iPad4,2", "iPad4,3":
        deviceModel = .iPadAir
    case "iPad4,7", "iPad4,8", "iPad4,9":
        deviceModel = .iPadMini3
    case "iPad5,1", "iPad5,3", "iPad5,4":
        deviceModel = .iPadAir2
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":
        deviceModel = .iPhone4
    case "iPhone4,1":
        deviceModel = .iPhone4S
    case "iPhone5,1", "iPhone5,2":
        deviceModel = .iPhone5
    case "iPhone5,3", "iPhone5,4":
        deviceModel = .iPhone5C
    case "iPhone6,1", "iPhone6,2":
        deviceModel = .iPhone5S
    case "iPhone7,2":
        deviceModel = .iPhone6
    case "iPhone7,1":
        deviceModel = .iPhone6Plus
    case "iPod5,1":
        deviceModel = .iPod5
    case "x86_64", "i386":
        deviceModel = .simulator
    default:
        deviceModel = .unknown
    }
    
    return deviceModel
}

func deviceType() -> UIUserInterfaceIdiom {
    return UIDevice.current.userInterfaceIdiom
}
