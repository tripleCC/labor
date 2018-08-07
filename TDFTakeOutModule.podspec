#
# Be sure to run `pod lib lint TDFTakeOutModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TDFTakeOutModule'
  s.version      = "0.2.3"
  s.summary          = 'TDFTakeOutModule 外卖模块.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://git.2dfire-inc.com/ios/TDFTakeOutModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shanmei' => 'shanmei@2dfire.com' }
  s.source           = { :git => 'http://git.2dfire-inc.com/ios/TDFTakeOutModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TDFTakeOutModule/Classes/**/**/*'
  
  s.resources = 'TDFTakeOutModule/Assets/*.{png,json}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'TDFMapLocationViewController'
  s.dependency 'TDFMediatorKit'
  s.dependency 'TDFAPIHUDPresenter'
  s.dependency 'TDFCore'
  s.dependency 'TDFAPIKit'
  s.dependency 'TDFLogger'
  s.dependency 'TDFBatchOperation'
  s.dependency 'TDFHelpDocumentKit'
  s.dependency 'TDFResources/TDFFooterButtonResources'
  s.dependency 'TDFComponents'
  s.dependency 'TDFUniversalPageModule'
  s.dependency 'MJRefresh'
  s.dependency 'TDFAliPaySDK'
  s.dependency 'TDFCommonUtility'
  s.dependency 'PinYin4Objc'
  s.dependency 'TDFDynamicPage'
  s.dependency 'TDFShopQRcodeModule'
  
  # 源码配置都放这里面
  tdfire_source_configurator = lambda do |s|
    s.source_files = "TDFTakeOutModule/**/*.{h,m}"
    s.public_header_files = "TDFTakeOutModule/**/*.h"
  end

 # 这一块原样拷贝即可（记得放在最后面）
  unless %w[tdfire_set_binary_download_configurations tdfire_source tdfire_binary].reduce(true) { |r, m| s.respond_to?(m) & r }

    tdfire_source_configurator.call s 
  else
    s.tdfire_source tdfire_source_configurator
    s.tdfire_binary tdfire_source_configurator
    s.tdfire_set_binary_download_configurations
  end
end
