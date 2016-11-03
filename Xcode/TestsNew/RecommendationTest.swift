//
//  RecommendationTest.swift
//  Examples
//
//  Created by arsen.vartbaronov on 01/11/16.
//  Copyright © 2016 Webtrekk. All rights reserved.
//

import Nimble
import Webtrekk

class RecommendationTest: WTBaseTestNew {
    
    override func getCongigName() -> String? {
        return String("webtrekk_config_recommendations")
    }
    
    
    func testComplexRecommendations(){
        recoTestBasic(name: "complexReco", productID: "085cc2g007")
    }
    
    func testSimpleRecommendations(){
        recoTestBasic(name: "simpleReco")
    }
    
    func testEmptyRecommendations(){
        recoTestBasic(name: "emptyTest", productID: nil, countValidation: 0)
    }
    
    //will crash if test not passed.
    func recoTestBasic(name: String, productID: String? = nil, countValidation count: Int = 1){
        
        let recoController = RecommendationTableViewController()
        
        recoController.productId = productID
        recoController.recommendationName = name
        
        recoController.beginAppearanceTransition(true, animated: false)
        recoController.endAppearanceTransition()
        
        
        expect(recoController.lastResult).toEventually(equal(RecommendationQueryResult.ok), timeout: 5)
        
        if count > 0 {
            expect(recoController.products?.count).to(beGreaterThanOrEqualTo(count))
        } else {
            expect(recoController.products?.count).to(equal(0))
        }
    }
}
