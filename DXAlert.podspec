#
# Be sure to run `pod lib lint DXAlert.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DXAlert'
  s.version          = '1.0.6'
  s.summary          = 'A short description of DXAlert.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/douglas525264/DXAlert'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'douglas525264' => 'xin.dong@dewmobile.net' }
  s.source           = { :git => 'https://github.com/douglas525264/DXAlert.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DXAlert/Classes/**/*'
  
   s.resource_bundles = {
     'DXAlert' => ['DXAlert/Assets/*.png']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'Photos', 'WebKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'Masonry'
  s.dependency 'JPush'
  
  

end
