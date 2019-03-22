#
# Be sure to run `pod lib lint SysdataSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                      = 'SysdataSwift'
  s.version                   = '0.1.1'
  s.platform                  = :ios
  s.ios.deployment_target     = '9.0'
  s.swift_version             = '4.2'
  s.summary                   = 'Sysdata architecture and utilities library'
  s.homepage                  =  'http://www.sysdata.it'
  s.social_media_url          =  'https://www.facebook.com/sysdata.it/'
  s.author                    = { 'Guido Sabatini' => 'guido.sabatini@sysdata.it' }
  s.source                    = { :git => 'https://github.com/SysdataSpA/SysdataSwift.git', :tag => s.version.to_s }
  s.license                   =  { :type => 'APACHE', :file => 'LICENSE' }
  s.description               = <<-DESC
Sysdata architecture and utilities library.
It contains:
* Core subspec:
** a container implementation
** a basic operation implementation
** extensions and utilities
** a Result implementation

* MVPC subspec:
** MVP and Coordinator pattern base protocols and classes
** a Context implementation

* Promise subspec:
** a basic promise implementation
                       DESC
  
  ### Subspecs

  s.subspec 'Core' do |core|

    core.source_files   = 'SysdataSwift/Classes/Core/**/*.{swift}'
    core.preserve_paths = 'SysdataSwift/Classes/Core/**'

  end

  s.subspec 'MVPC' do |mvpc|

    mvpc.source_files   = 'SysdataSwift/Classes/MVPC'
    mvpc.preserve_paths = 'SysdataSwift/Classes/MVPC'
    mvpc.dependency     'SysdataSwift/Core'

  end

  s.subspec 'Promise' do |prms|

    prms.source_files   = 'SysdataSwift/Classes/Promise'
    prms.preserve_paths = 'SysdataSwift/Classes/Promise'
    prms.dependency     'SysdataSwift/Core'

  end

end
