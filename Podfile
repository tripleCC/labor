source 'git@git.2dfire-inc.com:qingmu/private_cocoapods.git'
platform :ios, '8.0'


plugin 'cocoapods-tdfire-binary'

# tdfire_use_binary!
# tdfire_use_source_pods ['TDFModuleKit']

target 'PodE_Example' do
  pod 'PodE', :path => '../'

  pod 'PodA', :git => 'git@git.2dfire-inc.com:qingmu/PodA.git', :branch => 'release/0.2.3'
  pod 'PodB', :git => 'git@git.2dfire-inc.com:qingmu/PodB.git', :branch => 'release/0.2.0'
  pod 'PodD', :git => 'git@git.2dfire-inc.com:qingmu/PodD.git', :branch => 'release/0.2.2'

  target 'PodE_Tests' do
    inherit! :search_paths

    
  end
end
