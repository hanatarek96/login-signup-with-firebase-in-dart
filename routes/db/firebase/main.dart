import 'dart:convert';

import 'package:http/http.dart' as http;
var userId;
final String firebaseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';
final String apiKey = 'AIzaSyDreQCNmimnvoJESFbMslPUgkdvICMPHII'; // Replace with your Firebase API key
final String firebaseAuthUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';
final String firebaseFirestoreBaseUrl = 'https://firestore.googleapis.com/v1/projects/firsttrialdupli/databases/(default)/documents/users/$userId/info/$userId';
//final String firebaseFirestoreUrl = 'https://firestore.googleapis.com/v1/projects/firsttrialdupli/databases/(default)/documents/users/o17VC67mmno3HeO8jjtF/info/{USER_ID}'; // Replace with your Firestore URL
  

Future<void> signUpUser(String username, String phone, String email, String password) async {
  final url = '$firebaseAuthUrl:signUp?key=$apiKey';
  final response = await http.post(
    Uri.parse(url),
    body: json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    }),
  );

  final responseData = json.decode(response.body);
  if (response.statusCode == 200) {
    final token = responseData['idToken'];
     userId = responseData['localId'];

    // Save user data to Firestore
    await saveUserDataToFirestore(token, username, phone, email);

    print('User registered successfully!');
    print('Token: $token');
  } else {
    print('Error: ${responseData['error']['message']}');
  }
}

Future<void> saveUserDataToFirestore(dynamic token, String username, String phone, String email) async {

  final url = '$firebaseFirestoreBaseUrl?key=$apiKey';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'fields': {
        'username': {'stringValue': username},
        'phone': {'stringValue': phone},
        'email': {'stringValue': email},
      },
    }),
  );

  final responseData = json.decode(response.body);
  if (response.statusCode == 200) {
    print('User data saved to Firestore successfully!');
    print('Document ID: ${responseData['name']}');
  } else {
    print('Error: ${responseData['error']['message']}');
  }
}

Future<void> loginUser(String email, String password) async {
  final url = '$firebaseUrl:signInWithPassword?key=$apiKey';
  final response = await http.post(
    Uri.parse(url),
    body: json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    }),
  );

  final responseData = json.decode(response.body);
  if (response.statusCode == 200) {
    print('User logged in successfully!');
    print('Token: ${responseData['idToken']}');
  } else {
    print('Error: ${responseData['error']['message']}');
  }
}

void main() {
  // Usage example:
  signUpUser('JohnDoe', '+123456789', 'tes20@example.com', 'password123')
      .then((_) => loginUser('tes20@example.com', 'password123'));
}