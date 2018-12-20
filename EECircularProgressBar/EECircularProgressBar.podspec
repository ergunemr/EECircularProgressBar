Pod::Spec.new do |s|

  s.name         = "EECircularProgressBar"
  s.version      = "0.1"
  s.summary      = "A custom circular progress bar that provides transition between colors."

  s.homepage     = "https://github.com/ergunemr/EECircularProgressBar"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Emre" => "ergunemr@itu.edu.tr" }

  s.platform = :ios
  s.ios.deployment_target = '10.0'

  s.source       = { :git => "https://github.com/ergunemr/EECircularProgressBar.git", :tag => "#{s.version}" }
  s.swift_version = "4.2"
  s.source_files  = "EECircularProgressBar/EECircularProgressBar/*.{swift}"
  s.framework = "UIKit"
  s.requires_arc = true

end
