//
//  RecommendationForm.swift
//  StrongFuture
//
//  Created by Rustem Orazbayev on 1/6/23.
//

import SwiftUI

struct RecommendationForm: View {
    @State private var preference = "Chess"
    @State private var age = 25
    @State private var name = "John"
    @State private var time = "5"
    @State private var lim = "no"
    @State private var skill = "guitar"
    @State private var support = "no"
    @State private var concern = "no "
    
    @State private var showFormInvalidMessage = false
    
    @State private var errorMessage = ""
    
    func validateForm() {
        showFormInvalidMessage = false
        
        if age < 3 {
            errorMessage = "Kid is too young"
            showFormInvalidMessage = true
        }
        if preference.isEmpty {
            errorMessage = "The name cannot be blank"
            showFormInvalidMessage = true
        }
        
        if time.isEmpty {
            errorMessage = "The phone number cannot be blank"
            showFormInvalidMessage = true
        }
        
        if lim.isEmpty {
            errorMessage = "The email cannot be blank"
            showFormInvalidMessage = true
        }
    }
    
    var body: some View {
        
        Form{
            Section {
                TextField("Kid's Name", text: $name)
                Stepper(value: $age, step: 1) {
                    Text("Kid's Age:   \(age)")
                }
                TextField("Child's interests and preferences?", text: $preference)

                TextField("How much time available for the activity?", text: $time)
                    
                TextField("Any physical limitations?", text: $lim)
                TextField("Existing skills or talents of the children?", text: $skill)
                TextField("Will there be support from parents?", text: $support)
                TextField("Any concerns regarding the safety?", text: $concern)
                
                
            }
            Button(action: {
                validateForm()
                post()
            }) {
                Text("Confirm")
            }
        }
        .alert(isPresented: $showFormInvalidMessage) {
            Alert(title: Text("Error"), message: Text("Please correct the form data"), dismissButton: .default(Text("OK")))
        }
    }
    
    func post(){
        let parameters: [String: Any] = ["preference": preference, "age": String(age), "name": name, "time": time, "physical_limitation" : lim, "skill": skill, "support": support, "concern": concern ]

    // create the url with URL
    let url = URL(string: "http://192.168.224.230:8080/api/json/send-request")! // change server url accordingly
    
    // create the session object
    let session = URLSession.shared
    
    // now create the URLRequest object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST
    
    // add headers for the request
    request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
    //request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      // convert parameters to Data and assign dictionary to httpBody of request
      request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    } catch let error {
      print(error.localizedDescription)
      return
    }
    
    // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
              print("Post Request Error: \(error.localizedDescription)")
              return
            }
            print(data)
            print(response)
            
            // ensure there is valid response code returned from this HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
              print("Invalid Response received from the server")
              return
            }
            
            // ensure there is data returned
            guard let responseData = data else {
              print("nil Data received from the server")
              return
            }
            
            do {
              // create json object from data or use JSONDecoder to convert to Model stuct
              if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [Any] {
                print(jsonResponse)
                // handle json response
              } else {
                print("data maybe corrupted or in wrong format")
                throw URLError(.badServerResponse)
              }
            } catch let error {
              print(error.localizedDescription)
            }
          }
          // perform the task
          task.resume()

            
        }
}

