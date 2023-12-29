//
//  File.swift
//  
//
//  Created by Kael Yang on 2020/5/29.
//

import Vapor
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension SurgeController {
    func convert(_ req: Request) throws -> EventLoopFuture<AnyResponse> {
        let urls = req.extractOneOrMoreUrl(key: "urls")

        guard urls.count > 0 else {
            throw Abort(.badRequ