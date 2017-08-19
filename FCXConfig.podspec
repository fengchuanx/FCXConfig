
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "FCXConfig"
  s.version      = "0.0.1"
  s.summary      = "FCX’s FCXConfig."
  s.description  = <<-DESC
                    FCXConfig of FCX
                   DESC

  s.homepage     = "https://github.com/fengchuanx/FCXConfig"
  s.license      = "MIT"
  s.author             = { "fengchuanx" => "fengchuanxiangapp@126.com" }

  s.source       = { :git => "https://github.com/fengchuanx/FCXConfig.git", :tag => "0.0.1" }
  s.platform     = :ios, "8.0"

  #s.source_files  = "UMOnlineConfig/UMOnlineConfig.h"
 # s.vendored_libraries = "UMOnlineConfig/libUMOnlineConfig.a"
  s.libraries = "z"
   # s.frameworks  = "AdSupport", "CoreLocation", "SystemConfiguration", "CoreTelephony", "Security", "StoreKit", "QuartzCore", "AudioToolbox", "AVFoundation", "CoreGraphics", "CoreMedia", "EventKit", "EventKitUI", "MessageUI", "CoreMotion", "MediaPlayer", "MessageUI", "CoreLocation", "Foundation", "WebKit"
#s.libraries = "z", "iconv", "sqlite3", "stdc++", "c++"

 # s.dependency "UMengFeedback", "~> 2.3.4"
  s.dependency "UMengAnalytics", "~> 4.2.4"

end
