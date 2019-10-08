Pod::Spec.new do |spec|

  spec.name         = "LYYDispatch"
  spec.version      = "1.0.0"
  spec.summary      = "基于GCD的链式封装"

  spec.description  = <<-DESC
      基于系统GCD，采用链式思想、去除重复名称等方式进行的封装
                   DESC

  spec.homepage     = "https://github.com/liyaoyao613/LYYDispatch"
  spec.license      = "MIT"

  spec.author             = { "liyaoyao" => "liyaoyaoxrj@163.com" }

  spec.platform     = :ios, "8.0"

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.7"
  spec.source       = { :git => "https://github.com/liyaoyao613/LYYDispatch.git", :tag => "#{spec.version}" }

  spec.source_files  = "LYYDispatch/**/*.{h,m}"
  spec.public_header_files = "LYYDispatch/**/*.h"

  spec.static_framework = true

end
