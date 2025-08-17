//
//  ViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 11/06/2025.
//

import UIKit
import Lottie
import FirebaseCore

import FirebaseAuth

class LoginViewController: UIViewController {

    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var topTitleView: UIView!
    @IBOutlet weak var topTitleAppName: UILabel!
    @IBOutlet weak var registerGoogleButton: UIButton!
    
    let viewModel = LoginViewModel()
    var loadingOverlay: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func initViews(){
        
        topTitleAppName.layer.shadowOpacity = 0.3
        topTitleAppName.layer.shadowColor = UIColor.gray.cgColor
        topTitleAppName.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        topTitleView.layer.cornerRadius = 40
        topTitleView.layer.shadowOpacity = 0.3
        topTitleView.layer.shadowRadius = 10
        topTitleView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        emailInput.layer.borderWidth = 1
        emailInput.layer.borderColor = UIColor.black.cgColor
        emailInput.clipsToBounds = true
        
        passwordInput.layer.borderWidth = 1
        passwordInput.layer.borderColor = UIColor.black.cgColor
        passwordInput.clipsToBounds = true
        
    }
    
    @IBAction func onTapLogin(_ sender: UIButton) {
        showLoadingOverlay()
            Task {
                let (success, isFirstLogin, errorMessage) = await viewModel.login(
                    email: emailInput.text ?? "",
                    password: passwordInput.text ?? ""
                )

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hideLoadingOverlay()

                    if success && !isFirstLogin! {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let loaderVC = storyboard.instantiateViewController(withIdentifier: "AppLoaderViewController") as? AppLoaderViewController,
                              let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                              let window = sceneDelegate.window else { return }

                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                            window.rootViewController = loaderVC
                        }
                    }
                    else if success && isFirstLogin! {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let navController = storyboard.instantiateViewController(withIdentifier: "FirstLoginNavigationController") as? UINavigationController,
                              let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                            return
                        }

                        UIView.transition(with: sceneDelegate.window!,
                                          duration: 0.4,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                              sceneDelegate.window?.rootViewController = navController
                                          },
                                          completion: nil)
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                    else {
                        self.statusLabel.isHidden = false
                        self.statusLabel.text = errorMessage ?? "Login failed. Please try again."
                    }
                }
            }
    }
    
    @IBAction func onTapGoogleRegister(_ sender: Any) {
            Task {
                let (result, isFirstLogin, _) = await self.viewModel.connectWithGoogle(uiViewController: self)
                
                if result && !isFirstLogin! {
                    showLoadingOverlay()
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let sceneDelegate = UIApplication.shared.connectedScenes
                            .first?.delegate as? SceneDelegate else { return }
                        guard let loaderVC = storyboard.instantiateViewController(withIdentifier: "AppLoaderViewController") as? AppLoaderViewController else { return }

                        UIView.transition(with: sceneDelegate.window!,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: {
                                              sceneDelegate.window?.rootViewController = loaderVC
                                          },
                                          completion: nil)
                    }
                }
                else if result && isFirstLogin! {
                    showLoadingOverlay()
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let nav = storyboard.instantiateViewController(
                                withIdentifier: "FirstLoginNavigationController"
                        ) as? UINavigationController,
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                        else { return }

                        let window = sceneDelegate.window!
                        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
                            window.rootViewController = nav
                        }
                        window.makeKeyAndVisible()
                    }
                }
            }
    }
    
    
    func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = overlay.center
        spinner.startAnimating()

        overlay.addSubview(spinner)
        view.addSubview(overlay)

        loadingOverlay = overlay
    }
    
    func hideLoadingOverlay() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }
}

class RegisterViewController: UIViewController {
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var PasswordInput: UITextField!
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    private let viewModel = LoginViewModel()
    private var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        statusLabel.isHidden = true
        textFields = [fullNameInput,EmailInput,PasswordInput]
        for tf in textFields {
                    tf.delegate = self
                    tf.inputAccessoryView = createToolbar(for: tf)
                }
        let tapEvent = UIGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        contentView.addGestureRecognizer(tapEvent)
        contentView.isUserInteractionEnabled = true
    }

    
    @IBAction func onTapRegister(_ sender: UIButton) {
        Task {
            guard let fullName = fullNameInput.text, !fullName.isEmpty else {
                        statusLabel.isHidden = false
                        statusLabel.text = "Full name is required"
                        return
            }
            guard let email = EmailInput.text, !email.isEmpty else {
                statusLabel.isHidden = false
                statusLabel.text = "Email is required"
                return
            }
            guard let password = PasswordInput.text, !password.isEmpty else {
                statusLabel.isHidden = false
                statusLabel.text = "Password is required"
                return
            }

            let (success, errorMessage) = await viewModel.register(fullName: fullName,email: email,
                                                                   password: password)

            DispatchQueue.main.async { [weak self] in
                self?.statusLabel.isHidden = false
                if success {
                    self?.statusLabel.text = "Registration successful"
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.statusLabel.text = errorMessage ?? "Registration failed"
                }
            }
        }
    }
}

extension RegisterViewController:UITextFieldDelegate{
    
    func createToolbar(for textField: UITextField) -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            let up = UIBarButtonItem(title: "↑", style: .plain, target: self, action: #selector(goToPrevious))
            let down = UIBarButtonItem(title: "↓", style: .plain, target: self, action: #selector(goToNext))
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))

            toolbar.items = [up, down, flex, done]
            return toolbar
        }

        @objc func goToPrevious() {
            changeResponder(offset: -1)
        }

        @objc func goToNext() {
            changeResponder(offset: 1)
        }

        func changeResponder(offset: Int) {
            guard let current = textFields.firstIndex(where: { $0.isFirstResponder }) else { return }
            let next = current + offset
            if next >= 0 && next < textFields.count {
                textFields[next].becomeFirstResponder()
            }
        }

        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    }
    

