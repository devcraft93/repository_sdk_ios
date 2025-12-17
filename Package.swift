// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

private protocol Nameable {
    var name: String { get }
}

private extension Nameable {
    var asTargetDependency: Target.Dependency { Target.Dependency(stringLiteral: name) }
}

private extension RawRepresentable where RawValue == String {
    var name: String { rawValue }
}

// MARK: - Target and Package defintions

private enum Targets: String, Nameable {
    case iOSCoreSdk = "iOSCoreSdk"
}

private enum TestTargets: Nameable {
    case iOSCoreSdk

    var name: String {
        let suffix = "Tests"
        switch self {
        case .iOSCoreSdk:
            return Targets.iOSCoreSdk.name + suffix
        }
    }
}

private enum Packages: String, Nameable {
    case swiftyJSON = "SwiftyJSON"
    case promiseKit = "PromiseKit"
    case moya = "Moya"
    case firebase = "firebase-ios-sdk"

    var asPackageDependency: Package.Dependency {
        switch self {
        case .firebase:
            return .package(url: url, from: version)
        default:
            return .package(url: url, exact: version)
        }
    }


    private var url: String {
        switch self {
        case .swiftyJSON:
            return "https://github.com/SwiftyJSON/SwiftyJSON"
        case .promiseKit:
            return "https://github.com/mxcl/PromiseKit"
        case .moya:
            return "https://github.com/Moya/Moya"
        case .firebase:
            return "https://github.com/firebase/firebase-ios-sdk.git"
        }
    }
    
    private var version: Version {
        switch self {
        case .swiftyJSON:
            return Version(stringLiteral: "4.3.0")
        case .promiseKit:
            return Version(stringLiteral: "6.18.1")
        case .moya:
            return Version(stringLiteral: "12.0.1")
        case .firebase:
            return Version(stringLiteral: "10.18.0")
        }
    }
}

private enum Constants {
    static let packageName = "iOSCoreSdk"
    static let libraryName = packageName
}


// MARK: - Package definition

let package = Package(
    name: Constants.packageName,
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: Constants.libraryName,
            targets: [
                Targets.iOSCoreSdk.name
            ]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: / package url /, from: "1.0.0"),
        Packages.swiftyJSON.asPackageDependency,
        Packages.promiseKit.asPackageDependency,
        Packages.moya.asPackageDependency
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: Targets.iOSCoreSdk.name,
            dependencies: [
                Packages.swiftyJSON.asTargetDependency,
                Packages.promiseKit.asTargetDependency,
                Packages.moya.asTargetDependency
            ]
            
        ),
        .testTarget(
            name: TestTargets.iOSCoreSdk.name,
            dependencies: [Targets.iOSCoreSdk.asTargetDependency]
        )
    ]
)
