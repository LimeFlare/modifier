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

                let modifierContents = modifierResponses.compactMap { $0.body.flatMap { String(buffer: $0) } }

                guard modifierContents.count > 0 else {
                    return req.eventLoop.future(error: Abort(.badRequest, reason: "no content available, check url's availbility."))
                }

                var resources: Set<URL> = []
                let groupModifiers: [Surge.GroupModifier] = modifierContents.flatMap { urlContent -> [Surge.GroupModifier] in
                    let result = Surge.GroupModifier.extract(from: urlContent)
                    result.resources.forEach({ resources.insert($0) })
                    return result.groupModifiers
                }

                return resources.map { url in req.client.get(URI(string: url.absoluteString)).map { ($0, url) } }
                    .flatten(on: req.eventLoop)
                    .and(value: groupModifiers)
        }.flatMap { resourceResponses, groupModifiers -> EventLoopFuture<AnyResponse> in
            var resources: Surge.GroupModifier.Resources = [:]
            resourceResponses.forEach { clientResponse, url in
                if (200..<300).contains(clientResponse.status.code),
                    let body = clientResponse.body {
                    resources[url] = String(buffer: body).trimmingCharacters(in: .newlines)
                }
            }

            let skipNormalProxy = req.getBool(key: "skipNormalProxy") ?? req.getBool(key: "skipnormalproxy") ?? true
            let profile = Surge.generate(with: groupModifiers, resources: resources, skipNormalProxy: skipNormalProxy