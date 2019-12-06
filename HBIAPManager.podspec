

Pod::Spec.new do |spec|


  spec.name         = "HBIAPManager"
  spec.version      = "0.0.1"
  spec.summary      = "In App Purchase"
  spec.description  = <<-DESC
  	一个内购组件
                   DESC

  spec.homepage     = "https://www.shenhongbang.cc"

  spec.license      = "MIT"

  spec.author       = { "jiutianhuanpei" => "shenhongbang@163.com" }


  spec.platform     = :ios, "3.0"



  spec.source       = { :git => "https://github.com/jiutianhuanpei/HBIAPManager.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "HBIAPManager/*.{h,m}"

  spec.framework  = "StoreKit"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
