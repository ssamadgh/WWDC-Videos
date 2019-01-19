
Pod::Spec.new do |s|

  s.name         = "Coverflow"
  s.version      = "0.1.0"
  s.summary      = "Coverflow Implementation using UICollectionView"

  s.description  = <<-DESC
                   This is an iPhone project implementing Coverflow using iOS 6 UICollectionViews and a custom UICollectionViewLayout
                   DESC

  s.homepage     = "https://github.com/schwa/Coverflow"
  s.screenshots  = "https://s3.amazonaws.com/f.cl.ly/items/3Q13362C31040D2M3j2i/Screen%20Shot%202012-09-25%20at%2011.40.22%20AM.png"
  s.license      = {:type => 'BSD',
                    :text =>
                       "Created by Jonathan Wight on 9/24/12.
                        Copyright 2012 Jonathan Wight. All rights reserved.

                        Redistribution and use in source and binary forms, with or without modification, are
                        permitted provided that the following conditions are met:

                        1. Redistributions of source code must retain the above copyright notice, this list of
                        conditions and the following disclaimer.

                        2. Redistributions in binary form must reproduce the above copyright notice, this list
                        of conditions and the following disclaimer in the documentation and/or other materials
                        provided with the distribution.

                        THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
                        WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
                        FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
                        CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
                        CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
                        SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
                        ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
                        NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
                        ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
                    }

  s.authors            = { "schwa" => "schwa@toxicsoftware.com" }

  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/schwa/Coverflow.git", :tag => s.version.to_s}
  s.source_files  = "Coverflow/*.{h,m,mm,cpp}"

  s.frameworks = "CoreGraphics", "QuartzCore"
  s.requires_arc = true

end
