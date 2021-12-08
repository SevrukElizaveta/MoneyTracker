//
//  SignUp.swift
//  MoneyTracker
//
//  Created by Mikhail Lyapich on 7.12.21.
//

import SwiftUI

enum LoggedInUser {
    static var value: User!
}

struct SignUp: View {
    @State var shouldPresentMainView = false

    @ObservedObject private var userNameValidator = TextValidator(
        validate: { _ in true },
        validationText: "User name shouldn't be empty"
    )

    @ObservedObject private var passwordValidator1 = TextValidator(
        validate: { $0.count > 8 },
        validationText: "Password should have more than 8 symbols"
    )

    @ObservedObject private var passwordValidator2 = TextValidator(
        validate: { _ in true },
        validationText: "Passwords do not match"
    )

    @State private var showingAlert = false


    var body: some View {

            VStack {
                Form {
                    Section(
                        header: Text("User name"),
                        footer: Text(userNameValidator.validationPrompt).foregroundColor(.red)
                    ) {
                        TextField("Name", text: $userNameValidator.text)
                    }

                    Section(
                        header: Text("Password"),
                        footer:
                            Text(
                                passwordValidator1.validationPrompt.appending("\n\(passwordsDoNotMatch())")
                            ).foregroundColor(.red)
                    ) {
                        SecureField("Password", text: $passwordValidator1.text)
                        SecureField("Confirm password", text: $passwordValidator2.text)
                    }
                }

                Button(action: {
                    let viewContext = PersistenceController.shared.container.viewContext
                    let name = userNameValidator.text
                    let request = User.fetchRequest()
                    request.predicate = NSPredicate(format: "name == %@", name)
                    do {
                        let result = try viewContext.fetch(request)
                        if !result.isEmpty {
                            showingAlert = true
                        } else {
                            let user = User(context: viewContext)
                            user.id = UUID()
                            user.name = userNameValidator.text
                            user.password = passwordValidator1.text
                            try viewContext.save()
                            LoggedInUser.value = user
                            shouldPresentMainView = true
                        }
                    } catch {
                        print("failed \(error)")
                    }
                }) {
                    Text("Sign Up").multilineTextAlignment(.center)
                }
                .disabled(!self.passwordValidator1.isValid || !self.userNameValidator.isValid || !self.passwordValidator2.isValid || !passwordsDoNotMatch().isEmpty )
                .alert("There is already user with such username", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }

                Spacer()
                .fullScreenCover(isPresented: $shouldPresentMainView, onDismiss: nil) {
                    MainView()
                }
            }
            .navigationTitle("Sign Up")
//                .navigationBarItems(leading: cancelButton, trailing: saveButton)
    }

    func passwordsDoNotMatch() -> String {
        let p1 = self.passwordValidator1.text
        let p2 = self.passwordValidator2.text
        guard !p1.isEmpty && !p2.isEmpty else { return "" }

        return p1 == p2 ? "" : "Passwords do not match"
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
