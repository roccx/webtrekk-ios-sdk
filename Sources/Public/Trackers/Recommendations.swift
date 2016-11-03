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
//  Created by arsen.vartbaronov on 27/10/16.
//
//
import Foundation

public protocol Recommendation: class {
    
    /**
     * returns recommendation URL configured for this product. List of recommendations are defined in
     * <recommendations> tag in config XML. Recommendation are returned as URL based on provided key value. If key isn't defined it returns nil*/
    func getRecomendationURL(key: String) -> URL?

    /**
     * Init query for recommendation. Need call call() function to complete query. 
     * name is name of recomendation in your config.xml
     * callback is callback for getting results.
     * returns link to self of current instance or nil if recomendationName can't be resolved to reco URL.
     */
    func queryRecommendation(callback: RecommendationCallback, name recomendationName: String) -> Recommendation?
    /**
     * Set product ID for request recommendation call. If product ID nil it will be ignored. Need call call() function to complete query.
     * returns link to self of current instance.
     */
    func setProductID(id: String?) -> Recommendation

    /**
     * Call recommendation. Result will be provided in callback that was set in queryRecommendation
     */
    func call()
}

public typealias RecommendationValuesMap = [String: RecommendationProductValue]

public protocol RecommendationProduct {
    var id: String {get}
    var title: String {get}
    subscript (key: String) -> RecommendationProductValue? {get}
    var values: RecommendationValuesMap {get}
}

public struct RecommendationProductValue{
    public let type: String
    public let value: String
}

public protocol RecommendationCallback: class {
    /** returns list of RecommendationProducts and query result from server and connection error in case of connection error*/
    func onReceiveRecommendations(products: [RecommendationProduct]?, result: RecommendationQueryResult, error: Error? )
}

public enum RecommendationQueryResult {
    case ok,
    no_placement_found,
    no_account_id_found,
    recommendation_api_deactivated,
    no_connection,
    incorrect_url_format,
    incorrect_response,
    no_data_received
}
