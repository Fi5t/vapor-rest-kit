//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.05.2020.
//

import Vapor
import Fluent

protocol AuthChildrenResourceModelProviding: ChildrenResourceModelProviding where RelatedModel: Authenticatable {

}

extension AuthChildrenResourceModelProviding {
    var rootIdComponentKey: String { "me" }
    var rootIdPathComponent: PathComponent { return PathComponent(stringLiteral: "\(self.rootIdComponentKey)") }

    func findRelated(_ req: Request) throws -> EventLoopFuture<RelatedModel> {
        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop.makeSucceededFuture(related)
    }
}
