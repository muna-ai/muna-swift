//
//  BuildHandler.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/23/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import PackagePlugin
import XcodeProjectPlugin

@main
struct EmbedPlugin: BuildToolPlugin, XcodeBuildToolPlugin {

    func createBuildCommands (
        context: XcodeProjectPlugin.XcodePluginContext,
        target: XcodeProjectPlugin.XcodeTarget
    ) throws -> [PackagePlugin.Command] {
        let tool = try context.tool(named: "FunctionEmbedder")
        let toolPath = tool.path
        return [
            .buildCommand(
                displayName: "Embed Function predictors",
                executable: toolPath,
                arguments: [
                    context.pluginWorkDirectory
                ]
            )
        ]
    }

    func createBuildCommands (context: PluginContext, target: Target) throws -> [Command] {
        return []
    }
}
