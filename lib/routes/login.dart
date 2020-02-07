import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/constUrl.dart';

import 'package:flutter_app/common/localShare.dart';
import 'package:flutter_app/widgets/customViews.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _account;
  String _password;
  bool pwdShow = false;

  //表单验证方法
  void _forSubmitted(BuildContext context) {
    var _form = _formKey.currentState;
    if (_form.validate()) {
      _form.save();
      login(context, _account.trim(), _password.trim());
    }
    else {
      AlertDialog(
        content: Text("账号密码错误"),
        actions: <Widget>[
          FlatButton(
            child: Text("确定"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    }
  }

  //登录
  void login(BuildContext context, String account, String password) async {
    showDialog(
        context: context,
        builder: (context) {
          return LoadingDialog(content: "登录中，请稍后......");
        });
    FormData formData =
    FormData.fromMap({"username": account, "password": password});
    Response res = await Dio().post(Constant.LOGIN, data: formData);
    if (res.statusCode == 200) {
      Navigator.pop(context);
      print(res);
      // 数据缓存
      if (res.data['code'] == 200) {
        String name = res.data['info'][0]['name'];
        String academy = res.data['info'][0]['academy'];
        String major = res.data['info'][0]['major'];
        String stuId = account;
        String stuPasswd = password;
        List<String> list = new List();
        list.add(name);
        list.add(academy);
        list.add(major);
        list.add(stuId);
        list.add(stuPasswd);
        store(list);
        print('loginflag');
        print(LocalShare.loginFlag);
        Navigator.pushReplacementNamed(context, '/main');
        print('login end');
      } else {
        showDialog(
            context: context,
            child: AlertDialog(
              content: Text("账号密码错误"),
              actions: <Widget>[
                FlatButton(
                  child: Text("确定"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
      }
    }
  }

  // 本地存储
  void store(List<String> list) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(LocalShare.IS_LOGIN, true);
    sharedPreferences.setStringList(LocalShare.STU_INFO, list);
    print('in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                colors: [Colors.redAccent, Colors.orange]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 55),
              Image(
                width: 250,
                height: 191,
                image: AssetImage('assets/imgs/login_background.png'),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 5 * 4,
                      child: TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        initialValue: '',
                        decoration: new InputDecoration(
                            labelText: '学号', prefixIcon: Icon(Icons.person)),
                        onChanged: (val) {
                          _account = val;
                        },
                      ),
                    ),
                    SizedBox(height: 7),
                    Container(
                      width: MediaQuery.of(context).size.width / 5 * 4,
                      child: TextFormField(
                        initialValue: '',
                        obscureText: !pwdShow,
                        decoration: new InputDecoration(
                            labelText: '密码',
                            hintText: "强智教务系统密码",
                            suffixIcon: IconButton(
                                icon: Icon(pwdShow
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    pwdShow = !pwdShow;
                                  });
                                }),
                            prefixIcon: Icon(Icons.lock_outline)),
                        onChanged: (val) {
                          _password = val;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        colors: [Colors.redAccent, Colors.orange]),
                    borderRadius: BorderRadius.circular(20.0)),
                child: FlatButton(
                  child: Text("登录"),
                  onPressed: () => _forSubmitted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}