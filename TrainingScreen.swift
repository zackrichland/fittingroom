        // ... inside startTraining, before creating URLSession task ...
        let edgeFunctionUrl = URL(string: "\(supabaseUrl)/functions/v1/train-lora")!
        var request = URLRequest(url: edgeFunctionUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.httpBody = requestBody
        
        // Set a longer timeout (e.g., 180 seconds)
        request.timeoutInterval = 180.0 

        print("Sending request to Edge Function: \(edgeFunctionUrl)")

        // Create and resume the data task
        let (data, response) = try await URLSession.shared.data(for: request)
        // ... rest of response handling ... 