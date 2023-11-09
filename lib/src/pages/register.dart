import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:manlivetoung/src/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _gender = '2';
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  late final String url = 'http://10.0.2.2:3000';

  Future<dynamic> _signUp() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String nickname = _nicknameController.text;
    String type = _gender;
    dynamic savedUserInfo;

    const String url = 'http://10.0.2.2:8080/api/user';

    dynamic isSigned = await AuthManage().createUser(username, password);

    if (isSigned == true) {
      http.Response response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "id": username,
            "nickname": nickname,
            "password": password,
            "type": type,
          }));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      print('데이터 전달 불가능');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "회원가입",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 24.0),

              Column(
                children: <Widget>[
                  RadioListTile(
                    title: Text('건성'),
                    value: '건성',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('복합성'),
                    value: '복합성',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('지성'),
                    value: '지성',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ],
              ),

// 피부타입 표시 부분

              TextButton(
                child: Text('피부타입 테스트하기'),
                onPressed: () {
                  Navigator.pushNamed(context, '/skinTypeTest');
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                child: Text('회원가입'),
                onPressed: () {
                  _signUp();
                  // 회원가입 버튼 동작 구현
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
