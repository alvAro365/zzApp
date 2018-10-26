//
//  StartViewController.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-05.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import AlertOnboarding
import OpenSansSwift

class StartViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var loginStack: UIStackView!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var logo: UIImageView!
    
    // MARK: Properties
    private let dataHelper = DataProvider()
    private let serverOps = ServerOps()
    private var userValues: [String:Any]?
    let child = SpinnerViewController()
    var loginFacebook: LoginButton!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        OpenSans.registerFonts()
        signIn.titleLabel?.font = UIFont.openSansFontOfSize(15)
        if(dataHelper.getDefaultUser() == nil) {
            perform(#selector(showOnBoarding), with: nil, afterDelay: 0)
        }
//        _ = HealthKit()
        navigationItem.setHidesBackButton(true, animated: true)

        loginFacebook = LoginButton(readPermissions: [.publicProfile, .email, .userBirthday, .userGender, .userLocation])
        loginFacebook.delegate = self

        if User.sharedInstance.appId == "" {
            loginFacebook.isHidden = true
            signIn.isHidden = true
            logo.isHidden = true
        }
        

        signIn.layer.cornerRadius = 3
        loginStack.insertArrangedSubview(loginFacebook, at: 1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeSpinnerView()
        showHiddenViews()
    }
    
    // MARK: Navigation
    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue) {
        let source = sender.source as? SignInViewController
        userValues = source?.valuesDictionary
        loadUserData()
    }
}

// MARK: LoginButtonDelegate
extension StartViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("User cancelled login")
        case .success(_ , _ , let token):
            print(result)
            print("Logged in with ID: " + token.userId!)
            let request = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender"], accessToken: token, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
            request.start { (connection, result) in
                switch result {
                case .failed(let error):
                    print(error)
                case .success(let graphResponse):
                    print(graphResponse)
                    if let responseResult = graphResponse.dictionaryValue {
                        print(responseResult)
                        guard let firstName = responseResult["first_name"] as? String,
                            let lastName = responseResult["last_name"] as? String,
                            let email = responseResult["email"] as? String else {
                                return
                        }
                        print(firstName, lastName, email)
                        User.sharedInstance.email = email
                        User.sharedInstance.name = firstName + " " + lastName
                    }
                }

            }
            self.createSpinnerView()
            serverOps.onDataLoad = { [weak self] (data) in
                self?.useData(data: data)
            }
            
            serverOps.loginWith(facebookID: token.userId!)
            if User.sharedInstance.id != "" {
                print("User exists")
            } else {
                print("Creating new user")
                User.sharedInstance.id = token.userId!
                dataHelper.saveUser(User.sharedInstance)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Logged out")
        
    }
}

    // MARK: - UITextFieldDelegate
extension StartViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func idChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if let text = sender.text {
            print(text)
        }
    }
    
    @IBAction func passwordChanged(_ sender: UITextField) {
        // TODO: handle password input
    }
}

// MARK: - Actions
private extension StartViewController {
    
    func loadUserData() {
        createSpinnerView()
        serverOps.onDataLoad = { [weak self] (data) in
            DispatchQueue.main.async {
                self?.removeSpinnerView()
                self?.navigateToLoggedInScreen()
            }
            
        }
//        serverOps.loginWith(customerID: User.sharedInstance.customerID)
        serverOps.startBalanceTest()
    }
    
    func useData(data: JSON) {
        print("Received data: ")
        print(data)
        let status = data["status"].stringValue
        print(status)
        
//        status == "LOAD SERVER VERSION" ? loadUserData() : popCreateUserScreen()
        
        status == "LOAD SERVER VERSION" ? popCreateUserScreen() : popCreateUserScreen()
    }
    
    @objc func loginClicked() {
        print("Facebook login clicked")
    }
    
    
    @objc func showOnBoarding() {
        print("showing on boarding")
        let images = ["logo.png", "logo.png", "logo.png", "logo.png", "logo.png"]
        let descriptions = ["Balance your life in 120 days!", "Take the Balance test", "Start using your Balance products", "Go to www.zinzinotest.com", "Take a new Balance test after 120 days"]
        let titles = ["Zinzino Balance", "Step 1", "Step 2", "Step 3", "Step 4"]
        
        let alertView = AlertOnboarding(arrayOfImage: images, arrayOfTitle: titles, arrayOfDescription: descriptions)
        alertView.delegate = self
        alertView.colorButtonBottomBackground = UIColor(hexString: "#440099").withAlphaComponent(0.0)
        alertView.colorForAlertViewBackground = UIColor(hexString: "#440099").withAlphaComponent(0.0)
        alertView.colorPageIndicator = .white
        alertView.colorCurrentPageIndicator = UIColor(hexString: "#440099")
        alertView.colorButtonText = UIColor.white
        
        alertView.show()
    }
    
    @IBAction func sigInTapped(_ sender: UIButton) {
        //        createSpinnerView()
        //        if let id = enterIdField.text {
        //            serverOps.onDataLoad = { [weak self] (data) in
        //                self?.useData(data: data)
        //            }
        //            serverOps.loginWith(customerID: id)
        //        }
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    
    
    func navigateToLoggedInScreen() {
        self.dataHelper.saveUser(User.sharedInstance)
        self.removeSpinnerView()
        if let tabBarVc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            //                self.navigationController?.pushViewController(vc, animated: true)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabBarVc
        }
    }
    
    func popCreateUserScreen() {
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    
    func createSpinnerView() {
        
        addChildViewController(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func removeSpinnerView() {
        self.child.willMove(toParentViewController: nil)
        self.child.view.removeFromSuperview()
        self.child.removeFromParentViewController()
        
    }
    
    func showHiddenViews() {
        loginFacebook.isHidden = false
        signIn.isHidden = false
        logo.isHidden = false
    }
}

extension StartViewController: AlertOnboardingDelegate {
    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int) {
        print("Onboarding skipped the \(currentStep) and the max step he/she saw was the number \(maxStep)" )
        _ = HealthKit()
        showHiddenViews()
    }
    
    func alertOnboardingCompleted() {
        print("Onboarding completed")
        _ = HealthKit()
        showHiddenViews()
    }
    
    func alertOnboardingNext(_ nextStep: Int) {
        print("Next step triggered!\(nextStep)")
    }
}
