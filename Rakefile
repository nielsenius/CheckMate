# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'CheckMate'
  app.icons = ["icon_iphone_retina.png", "icon_ipad_retina.png"]
  app.prerendered_icon = true
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = true
  app.frameworks << 'MediaPlayer'
  
  app.device_family = [:iphone]
  app.interface_orientations = [:portrait]
  
  app.sdk_version = '7.1'
  app.version = '1.3.0'
  
  app.identifier = 'com.mqn.checkmate'
  
  app.development do
    app.entitlements['get-task-allow'] = true
    app.codesign_certificate = 'iPhone Developer: Matthew Nielsen'
    app.provisioning_profile = 'CheckMate_development.mobileprovision'
  end
  
  app.release do
    app.codesign_certificate = 'iPhone Distribution: Matthew Nielsen'
    app.provisioning_profile = 'CheckMate_distribution.mobileprovision'
  end
end
