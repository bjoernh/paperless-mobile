import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperless_api/paperless_api.dart';
import 'package:paperless_mobile/core/repository/label_repository.dart';
import 'package:paperless_mobile/core/repository/state/indexed_repository_state.dart';
import 'package:paperless_mobile/features/edit_label/cubit/edit_label_cubit.dart';
import 'package:paperless_mobile/features/edit_label/view/label_form.dart';
import 'package:paperless_mobile/generated/l10n.dart';
import 'package:paperless_mobile/helpers/message_helpers.dart';
import 'package:paperless_mobile/constants.dart';

class EditLabelPage<T extends Label> extends StatelessWidget {
  final T label;
  final T Function(Map<String, dynamic> json) fromJsonT;
  final List<Widget> additionalFields;

  const EditLabelPage({
    super.key,
    required this.label,
    required this.fromJsonT,
    this.additionalFields = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditLabelCubit(
        context.read<LabelRepository<T>>(),
      ),
      child: EditLabelForm(
        label: label,
        additionalFields: additionalFields,
        fromJsonT: fromJsonT,
      ),
    );
  }
}

class EditLabelForm<T extends Label> extends StatelessWidget {
  final T label;
  final T Function(Map<String, dynamic> json) fromJsonT;
  final List<Widget> additionalFields;

  const EditLabelForm({
    super.key,
    required this.label,
    required this.fromJsonT,
    required this.additionalFields,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).genericActionEditLabel),
        actions: [
          IconButton(
            onPressed: () => _onDelete(context),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: LabelForm<T>(
        initialValue: label,
        fromJsonT: fromJsonT,
        submitButtonConfig: SubmitButtonConfig<T>(
          icon: const Icon(Icons.save),
          label: Text(S.of(context).genericActionUpdateLabel),
          onSubmit: context.read<EditLabelCubit<T>>().update,
        ),
        additionalFields: additionalFields,
      ),
    );
  }

  void _onDelete(BuildContext context) async {
    if ((label.documentCount ?? 0) > 0) {
      final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title:
                  Text(S.of(context).editLabelPageConfirmDeletionDialogTitle),
              content: Text(
                S.of(context).editLabelPageDeletionDialogText,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(S.of(context).genericActionCancelLabel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    S.of(context).genericActionDeleteLabel,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          ) ??
          false;
      if (shouldDelete) {
        try {
          context.read<EditLabelCubit<T>>().delete(label);
        } on PaperlessServerException catch (error) {
          showErrorMessage(context, error);
        } catch (error, stackTrace) {
          log("An error occurred!", error: error, stackTrace: stackTrace);
        }
        Navigator.pop(context);
      }
    } else {
      context.read<EditLabelCubit<T>>().delete(label);
      Navigator.pop(context);
    }
  }
}
