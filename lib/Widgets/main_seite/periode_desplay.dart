import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/app_bloc.dart';

class RechnungsDauer extends StatelessWidget {
  const RechnungsDauer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text('${state.period} Sec',
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
