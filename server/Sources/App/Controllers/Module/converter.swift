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
            throw Abort(.badRequest, reason: "no url specified")
        }

        URLCache.shared.removeAllCachedResponses()

        return urls.map { req.client.get(URI(string: $0.absoluteString)) }
            .flatten(on: req.eventLoop)
            .flatMap { modifierResponses -> EventLoopFuture<([(ClientResponse, URL)], [Surge.GroupModifier])> in

                let modifierContents = modifierResponses.compactMap { $0.body.flatMap {