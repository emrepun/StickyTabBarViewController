// swift-tools-version:5.1
import PackageDescription

let packageName = "StickyTabBarViewController"

let package = Package(name: packageName,
                      platforms: [.iOS(.v10)],
                      products: [.library(name: packageName,
                                          targets: [packageName])],
                      targets: [.target(name: packageName,
                                        path: "\(packageName)/Classes")],
                      swiftLanguageVersions: [.v5])
