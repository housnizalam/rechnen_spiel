import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/bloc/app_bloc.dart';

class NameGeber extends StatelessWidget {
  const NameGeber({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();

    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return TextFormField(
          onTap: () {
            if (name.text.isNotEmpty) {
              BlocProvider.of<AppBloc>(context).add(GiveNameEvent(name: name.text));
            }
          },
          style: const TextStyle(color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold),
          controller: name,
          decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              labelText: '  Deine Name',
              labelStyle: TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}
