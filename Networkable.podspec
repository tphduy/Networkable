#
# Be sure to run `pod lib lint Networkable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = 'Networkable'
  s.version = '2.0.0'
  s.summary = 'Ad-hoc network layer built on URLSession'
  s.description = <<-DESC
TODO: Add long description of the pod here.
  DESC
  s.homepage = 'https://github.com/tphduy/Networkable'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'duytph' => 'tphduy@gmail.com' }
  s.source = { :git => 'https://github.com/tphduy/Networkable.git', :tag => s.version.to_s }
  s.osx.deployment_target = '10.12'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '2.0'
  s.source_files = 'Sources/**/*'
  s.swift_versions = "5.7"
end
