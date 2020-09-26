// swift-tools-version:5.1
import PackageDescription

let package = Package(name: "Alamofire",
                      platforms: [.iOS(.v10)],
                      products: [.library(name: "StickyTabBarViewController",
                                          targets: ["StickyTabBarViewController"])],
                      targets: [.target(name: "StickyTabBarViewController",
                                        path: "StickyTabBarViewController/Classes")],
                      swiftLanguageVersions: [.v5])
