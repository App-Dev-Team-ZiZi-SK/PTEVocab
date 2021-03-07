# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

install! 'cocoapods',
         :deterministic_uuids => false

target 'PTEVocab' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PTEVocab
  pod 'Amplify'           # required amplify dependency
  pod 'Amplify/Tools'      # allows to call amplify CLI from within Xcode

  pod 'AmplifyPlugins'		      # support for GraphQL API

  pod 'AWSMobileClient'      # Required dependency
  pod 'AWSAuthUI'           # Optional dependency required to use drop-in UI
  pod 'AWSUserPoolsSignIn'  # Optional dependency required to use drop-in UI

  # Login with FB and Amplify/Cognito
  pod 'AWSFacebookSignIn'

  # Login with Google and Amplify/Cognito
  pod 'AWSGoogleSignIn'
  pod 'GoogleSignIn'

  # S3 storage Plugin
  pod 'AmplifyPlugins/AWSS3StoragePlugin'

  # Json
  pod 'SwiftyJSON', '~> 5.0.0'

  # DataFramework
  pod 'RealmSwift'
  pod 'Realm'
end
