//
//  
//  
//
//  Created by Sergey Kazakov on 29.04.2020.
//

import Vapor
import Fluent

protocol DeletableResourceController: ItemResourceControllerProtocol
    where
    Input: ResourceDeleteModel,
    Model == Input.Model {

    associatedtype Input
    associatedtype Model

    func delete(_ req: Request) throws -> EventLoopFuture<Output>

    var deleteHandler: Input { get }
}

extension DeletableResourceController where Self: ResourceModelProvider {
    func delete(_ req: Request) throws -> EventLoopFuture<Output> {
        let db = req.db
        return try self.find(req)
            .flatMap { self.deleteHandler.delete($0, req: req, database: db) }
            .map { Output($0, req: req) }
    }
}



