//
//  SignIn.swift
//  MoneyTracker
//
//  Created by Mikhail Lyapich on 7.12.21.
//

import SwiftUI

struct SignIn: View {
    @State var shouldPresentMainView = false
    @State var showingAlert = false

    @ObservedObject private var userNameValidator = TextValidator(
        validate: { _ in true },
        validationText: "User name shouldn't be empty"
    )

    @ObservedObject private var passwordValidator1 = TextValidator(
        validate: { _ in true },
        validationText: "Password should have more than 8 symbols"
    )

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(
                        header: Text("User name")
                    ) {
                        TextField("Name", text: $userNameValidator.text)
                    }

                    Section(
                        header: Text("Password")
                    ) {
                        SecureField("Password", text: $passwordValidator1.text)
                    }

                    Section {
                        NavigationLink(destination: SignUp()) {
                            Text("Sign Up")
                        }

                        Button("Sign In") {
                            let viewContext = PersistenceController.shared.container.viewContext
                            let name = userNameValidator.text
                            let password = passwordValidator1.text
                            let request = User.fetchRequest()
                            request.predicate = NSPredicate(format: "name == %@ && password == %@", name, password)
                            do {
                                let result = try viewContext.fetch(request)
                                if result.isEmpty {
                                    showingAlert = true
                                } else {
                                    LoggedInUser.value = result.first!
                                    shouldPresentMainView = true
                                    print("Sign In success")
                                }
                            } catch {
                                print("failed \(error)")
                            }
                        }
                        .disabled(!self.passwordValidator1.isValid || !self.userNameValidator.isValid)
                        .alert("There is no such user. Please try again", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                    }
                }
                Spacer()
                .fullScreenCover(isPresented: $shouldPresentMainView, onDismiss: nil) {
                    MainView()
                }
            }
            .navigationTitle("Sign In")
//                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
