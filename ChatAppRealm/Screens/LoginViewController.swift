//
//  LoginViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import RealmSwift
import UIKit

class LoginViewController: UIViewController {
  private var state: AppState!
  
  var stackView = UIStackView()
  var emailField = CATextField()
  var passwordField = CATextField()
  var callToActionButton = CAButton()
  
  lazy var checkboxButton: CAButton = {
    let button = CAButton()
    button.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
    button.setTitle("Register New User", for: .normal)
    button.setTitleColor(.label, for: .normal)
    button.tintColor = .label
    button.backgroundColor = .clear
    return button
  }()
  
  var newUser: Bool = true {
    didSet {
      checkboxButton.setImage(newUser ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square"), for: .normal)
      checkboxButton.setTitleColor(newUser ? .label : .secondaryLabel, for: .normal)
      checkboxButton.tintColor = newUser ? .label : .secondaryLabel
    }
  }
  
  init(state: AppState) {
    super.init(nibName: nil, bundle: nil)
    self.state = state
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    configureStackView()
  }
  
  private func configureViewController() {
    title = "ChatAppRealm"
    view.backgroundColor = .systemBackground
  }
  
  private func configureStackView() {
    view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .fill
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.spacing = 20
    
    NSLayoutConstraint.activate([
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
    
    emailField.set(placeholder: "Username/Email", showingSecureField: false)
    stackView.addArrangedSubview(emailField)
    
    passwordField.set(placeholder: "Password", showingSecureField: true)
    stackView.addArrangedSubview(passwordField)
    
    callToActionButton.set(title: "Sign Up")
    callToActionButton.addTarget(self, action: #selector(handleCallToActionButtonTapped), for: .touchUpInside)
    stackView.addArrangedSubview(callToActionButton)
    
    checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    stackView.addArrangedSubview(checkboxButton)
  }
  
  @objc private func handleCallToActionButtonTapped() {
    state.shouldIndicateActivity = true
    newUser ? signup() : login()
  }
  
  @objc private func checkboxTapped() {
    newUser.toggle()
    callToActionButton.setTitle(newUser ? "Sign Up" : "Log In", for: .normal)
  }
  
  private func showSnackBar(title: String) {
    UIHelpers.showSnackBar(title: title,
                           backgroundColor: .secondarySystemBackground,
                           view: self.view)
  }
  
  private func dismissSnackBar(title: String) {
    UIHelpers.hideSnackBar(title: title,
                           backgroundColor: .secondarySystemBackground,
                           view: self.view)
  }
  
  @objc private func signup() {
    guard
      let email = emailField.text, !email.isEmpty,
      let password = passwordField.text, !password.isEmpty else {
      UIHelpers.autoDismissableSnackBar(title: "Provide a valid email and password",
                                        image: UIImage(systemName: "exclamationmark.circle")!,
                                        backgroundColor: .systemYellow,
                                        textColor: .black,
                                        view: self.view)
      state.shouldIndicateActivity = false
      return
    }
    
    state.error = nil
    showSnackBar(title: "Creating Account")
    state.app.emailPasswordAuth.registerUser(email: email, password: password)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        self.state.shouldIndicateActivity = false
        self.dismissSnackBar(title: "Creating Account")
        switch completion {
        case .failure(let error):
          self.state.error = error.localizedDescription
          UIHelpers.autoDismissableSnackBar(title: error.localizedDescription.capitalized,
                                            image: UIImage(systemName: "xmark.circle")!,
                                            backgroundColor: .systemRed,
                                            view: self.view)
        case .finished:
          break
        }
      } receiveValue: { value in
        self.state.error = nil
        self.dismissSnackBar(title: "Creating Account")
        self.login()
      }
      .store(in: &state.subscribers)
  }
  
  @objc private func login() {
    guard
      let email = emailField.text, !email.isEmpty,
      let password = passwordField.text, !password.isEmpty else {
      UIHelpers.autoDismissableSnackBar(title: "Provide a valid email and password",
                                        image: UIImage(systemName: "exclamationmark.circle")!,
                                        backgroundColor: .systemYellow,
                                        textColor: .black,
                                        view: self.view)
      state.shouldIndicateActivity = false
      return
    }
    
    state.error = nil
    showSnackBar(title: "Logging in")
    state.app.login(credentials: .emailPassword(email: email, password: password))
      .receive(on: DispatchQueue.main)
      .sink { completion in
        self.state.shouldIndicateActivity = false
        self.dismissSnackBar(title: "Logging in")
        switch completion {
        case .failure(let error):
          self.state.error = error.localizedDescription
          UIHelpers.autoDismissableSnackBar(title: error.localizedDescription.capitalized,
                                            image: UIImage(systemName: "xmark.circle")!,
                                            backgroundColor: .systemRed,
                                            view: self.view)
        case .finished:
          break
        }
      } receiveValue: { user in
        self.state.error = nil
        self.dismissSnackBar(title: "Logging in")
        self.state.loginPublisher.send(user)
        self.pushProfileScreen()
      }
      .store(in: &state.subscribers)
  }
  
  func pushProfileScreen() {
    self.dismiss(animated: true)
  }
}
