import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const request = 'https://api.hgbrasil.com/finance?';

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response res = await http.get(Uri.parse(request));
  return json.decode(res.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  late double dolar;
  late double euro;

  void _realChanged(String text) async {
    if (text.isNotEmpty) {
      double real = double.parse(text);
      dolarControler.text = (real / dolar).toStringAsFixed(2);
      euroControler.text = (real / euro).toStringAsFixed(2);
    } else {
      _clearAll(1, dolarControler, euroControler);
    }
  }

  void _dolarChanged(String text) async {
    if (text.isNotEmpty) {
      double dolar = double.parse(text);
      realControler.text = (dolar * this.dolar).toStringAsFixed(2);
      euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    } else {
      _clearAll(2, realControler, euroControler);
    }
  }

  void _euroChanged(String text) async {
    if (text.isNotEmpty) {
      double euro = double.parse(text);
      realControler.text = (euro * this.euro).toStringAsFixed(2);
      dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);
    } else {
      _clearAll(3, realControler, dolarControler);
    }
  }

  Future<void> _clearAll(
      int i, TextEditingController a, TextEditingController b) async {
    switch (i) {
      case 1:
        a.text = '';
        b.text = '';
        break;
      case 2:
        a.text = '';
        b.text = '';
        break;
      case 3:
        a.text = '';
        b.text = '';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("\$ Conversor de moedas \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar Dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$ ", realControler, _realChanged),
                      const Divider(),
                      buildTextField(
                          'Dólares', 'US\$ ', dolarControler, _dolarChanged),
                      const Divider(),
                      buildTextField(
                          'Euros', '€ ', euroControler, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c,
    final Function(String) f) {
  return Form(
      child: Column(
    children: [
      TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          border: const OutlineInputBorder(),
          prefixText: prefix,
        ),
        style: const TextStyle(color: Colors.amber, fontSize: 25.0),
        onChanged: f,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
      )
    ],
  ));
}
