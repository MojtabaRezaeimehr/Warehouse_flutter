import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_amf/screens/settings/cubit/expansion_cubit.dart';
import 'package:warehouse_amf/screens/widgets/ip_config_card.dart';

class ConnectionSection extends StatefulWidget {
  const ConnectionSection({
    super.key,
  });

  @override
  State<ConnectionSection> createState() => _ConnectionSectionState();
}

class _ConnectionSectionState extends State<ConnectionSection> {
  var expansionController = ExpansibleController();

  @override
  Widget build(BuildContext context) {    var expansionCubit = BlocProvider.of<ExpansionCubit>(context);
    return BlocListener<ExpansionCubit, ExpansionState>(
      listener: (context, state) {
       if(state is! ConnectionExpanded && expansionController.isExpanded){
          expansionController.collapse();
        }
      },
      child: ExpansionTile(
        controller: expansionController,
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        collapsedBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
         onExpansionChanged: (value) {
          if (value) {
            expansionCubit.expandConnection();
          }
        },
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20),

        title: Text(
          'connection'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          const SizedBox(
            height: 300,
            child: IpConfigCard(
              showBackButton: false,
            ),
          ),
        ],
      ),
    );
  }
}
