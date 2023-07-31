import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/bloc/rechner_bloc.dart';

class AufgabeDarstellung extends StatelessWidget {
  const AufgabeDarstellung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: state.valuation.contains('failed') || state.valuation.contains('wins') || state.firstNumber == null
              ? Container()
              : Text(
                  '${state.firstNumber} ${state.calcOperation} ${state.secondNumber}',
                  style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold),
                ),
        );
      },
    );
  }
}
