//
//  AppAssembly.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/14/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import DITranquillity

class AppAssembly: DIAssembly {
    let publicModules: [DIModule] = []
    let internalModules: [DIModule] = [DomainLayerDIModule(), PresentationLayerDIModule()]
    let dependencies: [DIAssembly] = []
}
