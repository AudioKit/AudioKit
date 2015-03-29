Pod::Spec.new do |spec|
    spec.name                     = 'AudioKit'
    spec.version                  = '2.0'
    spec.authors                  = { 'Aurelius Prochazka' => 'audiokit@audiokit.io' }
    spec.license                  = { :type => 'LGPL' }
    spec.homepage                 = 'http://audiokit.io/'
    spec.source                   = { :git => 'https://github.com/audiokit/AudioKit.git', :tag => 'v2.0-03-26-2015' }
    spec.summary                  = 'Open-source audio synthesis, processing, & analysis platform.'

    spec.source_files             = 'AudioKit/Core Classes/**/*.{h,m}',
                                    'AudioKit/Instruments/**/*.{h,m}',
                                    'AudioKit/Notes/**/*.{h,m}',
                                    'AudioKit/Operations/**/*.{h,m}',
                                    'AudioKit/Parameters/**/*.{h,m}',
                                    'AudioKit/Sequencing/**/*.{h,m}',
                                    'AudioKit/Tables/**/*.{h,m}',
                                    'AudioKit/Utilities/**/*.{h,m,c}'

    spec.osx.deployment_target    = '10.10'
    spec.osx.frameworks           = 'CsoundLib64'
    spec.osx.vendored_frameworks  = 'AudioKit/Platforms/OSX/CsoundLib64.framework'
    spec.osx.source_files         = 'AudioKit/Platforms/OSX/*.{h,m}'

    spec.ios.deployment_target    = '8.0'
    spec.ios.libraries            = 'csound', 'sndfile'
    spec.ios.vendored_libraries   = 'AudioKit/Platforms/iOS/libs/libcsound.a', 'AudioKit/Platforms/iOS/libs/libsndfile.a'
    spec.ios.source_files         = 'AudioKit/Platforms/iOS/classes/*.{h,m}',
                                    'AudioKit/Platforms/iOS/headers/*.{h,hpp}'
end
