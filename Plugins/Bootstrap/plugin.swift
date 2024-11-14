//
//  plugin.swift
//  Function
//
//  Created by Yusuf Olokoba on 11/14/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import PackagePlugin
import XcodeProjectPlugin

@main
struct BootstrapProjectPlugin: CommandPlugin, XcodeCommandPlugin {

    func performCommand (context: PluginContext, arguments: [String]) throws { }

    func performCommand (context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        
    }
}
