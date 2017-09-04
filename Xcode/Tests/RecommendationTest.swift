//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by arsen.vartbaronov on 01/11/16.
//

import Nimble
import Webtrekk

class RecommendationTest: WTBaseTestNew {
    
    override func getConfigName() -> String? {
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
