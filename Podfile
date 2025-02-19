# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'ChatApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for ChatApp
  pod 'Firebase/Core', '~>10.29.0'
  pod 'Firebase/Database', '~>10.29.0'
  pod 'Firebase/Firestore', '~>10.29.0'
  pod 'Firebase/Storage', '~>10.29.0'
  pod 'Firebase/Messaging', '~>10.29.0'
  pod 'Firebase/Auth', '~>10.29.0'

  pod 'GoogleSignIn'

  pod 'JGProgressHUD','~>2.0.3'
  pod 'SDWebImage', '~>4.4.2'
  
  pod 'ImageSlideshow', '~> 1.9'
  pod 'SwiftAudioPlayer'
  
  # Factory
  pod "Factory"

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
  
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
