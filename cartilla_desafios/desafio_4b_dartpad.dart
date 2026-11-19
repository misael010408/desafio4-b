// Desafío 4B — pegá este archivo completo en https://dartpad.dev y ejecutalo.
import 'dart:convert';

class Address {
  final String city;
  final String zipcode;
  const Address({required this.city, required this.zipcode});
  factory Address.fromJson(Map<String, dynamic> json) =>
      Address(city: json['city'] as String, zipcode: json['zipcode'] as String);
}

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final Address address;
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.address,
  });
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        address: Address.fromJson(json['address'] as Map<String, dynamic>),
      );
}

const jsonUno = '''
{"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz",
 "address":{"street":"Kulas Light","city":"Gwenborough","zipcode":"92998-3874"}}
''';

const jsonLista = '''
[
 {"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz",
  "address":{"city":"Gwenborough","zipcode":"92998-3874"}},
 {"id":2,"name":"Ervin Howell","username":"Antonette","email":"Shanna@melissa.tv",
  "address":{"city":"Wisokyburgh","zipcode":"90566-7771"}}
]
''';

void main() {
  // Un usuario (objeto {...})
  final u = User.fromJson(jsonDecode(jsonUno) as Map<String, dynamic>);
  print('${u.id} - ${u.name} (${u.username}) ${u.email} - ${u.address.city} ${u.address.zipcode}');

  // Lista de usuarios (array [...])
  final lista = (jsonDecode(jsonLista) as List<dynamic>)
      .map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList();
  for (final x in lista) {
    print('${x.id}: ${x.name} - ${x.address.city}');
  }
}
