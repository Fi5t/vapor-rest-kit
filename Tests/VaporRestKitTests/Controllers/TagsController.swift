//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.05.2020.
//

@testable import VaporRestKit
import XCTVapor
import Vapor
import Fluent

struct TagControllers {
    struct TagController: VersionableController {

        let todoOwnerGuardMiddleware = RelatedResourceControllerMiddleware<User, Todo>(handler: { (user, todo, req, db) in
            db.eventLoop
                .tryFuture { try req.auth.require(User.self) }
                .guard( { $0.id == todo.user.id}, else: Abort(.unauthorized))
                .transform(to: (user, todo))
        })


        var apiV1: APIMethodsProviding {
            return Tag.Output
                .controller(eagerLoading: EagerLoadingUnsupported.self)
                .related(with: \Todo.$tags, relationName: nil)
                .collection(sorting: SortingUnsupported.self,
                            filtering: FilteringUnsupported.self)
        }

        func setupAPIMethods(on routeBuilder: RoutesBuilder, for endpoint: String, with version: ApiVersion) {
            switch version {
            case .v1:
                let todos = routeBuilder.grouped("todos")
                apiV1.addMethodsTo(todos, on: endpoint)
            }
        }
    }

    struct TagsForTodoController: VersionableController {
        var apiV1: APIMethodsProviding {
            let todoOwnerGuardMiddleware = RelatedResourceControllerMiddleware<Tag, Todo> { (tag, todo, req, db) in
                db.eventLoop
                    .tryFuture { try req.auth.require(User.self) }
                    .guard( { $0.id == todo.user.id}, else: Abort(.unauthorized))
                    .transform(to: (tag, todo))
            }

            return Tag.Output
                .controller(eagerLoading: EagerLoadingUnsupported.self)
                .related(with: \Todo.$tags, relationName: nil)
                .create(input: Tag.CreateInput.self, middleware: todoOwnerGuardMiddleware)
                .read()
                .update(input: Tag.UpdateInput.self, middleware: todoOwnerGuardMiddleware)
                .patch(input: Tag.PatchInput.self, middleware: todoOwnerGuardMiddleware)
                .collection(sorting: SortingUnsupported.self,
                            filtering: FilteringUnsupported.self)
        }

        func setupAPIMethods(on routeBuilder: RoutesBuilder, for endpoint: String, with version: ApiVersion) {
            switch version {
            case .v1:
                let todos = routeBuilder.grouped("todos")
                apiV1.addMethodsTo(todos, on: endpoint)
            }
        }

    }
}
