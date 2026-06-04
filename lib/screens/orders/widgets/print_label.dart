// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:printing/printing.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'dart:ui' as ui;
import 'package:warehouse_amf/screens/widgets/loading_dialog.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

class PrintLabel extends StatelessWidget {
  const PrintLabel({
    super.key,
    required this.order,
  });
  final Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        LoadingDialog.show(context);

        var config = LocalServices.appConfigRepo.fetchConfig();
        double labelSize = double.parse(config.labelSize);
        double fontSize = double.parse(config.fontSize);

        var data = {
          "orderId": order.id,
          "documentCode": order.documentNo ?? "-",
          "date": order.date.toPersianDate(digitType: NumStrLanguage.English)
        };

        //calculate label height
        var height = labelSize;
        int rowCount = 0;
        data.forEach((key, value) {
          var tp = TextPainter(
            textDirection: ui.TextDirection.ltr,
            text: TextSpan(
              text: "$key : $value",
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          )..layout(maxWidth: labelSize);
          rowCount += tp.computeLineMetrics().length;
        });

        height += rowCount * (fontSize * 1.2);

        var doc = pw.Document();
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            doc.addPage(pw.Page(
              pageFormat: PdfPageFormat(labelSize, height),
              build: (context) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                        child: pw.SvgImage(
                          svg: pw.Barcode.dataMatrix().toSvg(
                            data.toString(),
                            width: labelSize - 10,
                            height: labelSize - 10,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      ...data.entries.map(
                        (e) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(
                              bottom: 2,
                            ),
                            child: pw.Text(
                              "${e.key} : ${e.value}",
                              style: pw.TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                );
              },
            ));
            return await doc.save();
          },
        );
        LoadingDialog.dismiss();
      },
      child: ListTile(
        leading: const Icon(
          Icons.print,
        ),
        title: Text(Translations.printOutgoingLabel.name.tr()),
      ),
    );
  }
}
