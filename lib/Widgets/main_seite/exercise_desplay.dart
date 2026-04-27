import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/app_bloc.dart';

class AufgabeDarstellung extends StatelessWidget {
  const AufgabeDarstellung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: state.status == GameStatus.failed ||
                  state.status == GameStatus.won ||
                  state.firstNumber == null
              ? Container()
              : Text(
                  '${state.firstNumber} ${state.calcOperation!.operation} ${state.secondNumber}',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
        );
      },
    );
  }
}
