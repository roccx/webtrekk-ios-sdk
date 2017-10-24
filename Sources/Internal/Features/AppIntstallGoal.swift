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
//  Created by arsen.vartbaronov on 20.10.17.
//

import Foundation

class AppinstallGoal{
    
    private static let appinstallGoal = "appinstallGoal"
    private static let appinstallGoalProcessed = "appinstallGoalProcessed"
    private let sharedDefaults = UserDefaults.standardDefaults.child(namespace: "webtrekk")

    
    func setupAppinstallGoal(){
        guard !isAppinstallGoalProcessed() else {
            return
        }
        
        self.sharedDefaults.set(key: AppinstallGoal.appinstallGoal, to: true)
    }
    
    func checkAppinstallGoal() -> Bool{
        let goal = self.sharedDefaults.boolForKey(AppinstallGoal.appinstallGoal)
        return goal ?? false
    }
    
    func fininshAppinstallGoal(){
        if self.checkAppinstallGoal() {
            self.sharedDefaults.remove(key: AppinstallGoal.appinstallGoal)
            appinstallGoalProcessFinished()
        }
    }
    
    private func appinstallGoalProcessFinished(){
        self.sharedDefaults.set(key: AppinstallGoal.appinstallGoalProcessed, to: true)
    }

    private func isAppinstallGoalProcessed() -> Bool{
        return self.sharedDefaults.boolForKey(AppinstallGoal.appinstallGoalProcessed) ?? false
    }
}
