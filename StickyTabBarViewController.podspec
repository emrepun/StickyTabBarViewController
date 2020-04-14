#
#  Be sure to run `pod spec lint StickyTabBarViewController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = 'StickyTabBarViewController'
  s.version      = '0.0.3'
  s.summary      = 'A sticky and expandable view controller on top of TabBar'

  s.description  = <<-DESC
  StickyTabBarViewController provides a UI component that is similar to Spotify music player, Youtube's now playing view
  It provides the functionality for an application using UITabBarController to have a sticky, expandable and customizable
  view on top of tab bar.
                   DESC

  s.homepage     = 'https://github.com/emrepun/StickyTabBarViewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "emrepun" => "emrehavan@hotmail.com" }

  s.ios.deployment_target = '10.0'
  s.swift_version    = '5.0'

  s.source       = { :git => 'https://github.com/emrepun/StickyTabBarViewController.git', :tag => s.version.to_s }

  s.source_files  = 'StickyTabBarViewController/Classes/**/*'

end
