import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as PDFUTIL;
import 'package:pdf/widgets.dart' as PDF;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/beanmodel/orderbean/todayorderbean.dart';

class MyInvoicePdf extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyInvoicePdfState();
  }
}

class MyInvoicePdfState extends State<MyInvoicePdf> {
  bool isEntered = false;
  bool isLoading = true;
  TodayOrderMain invoiceBeand;
  dynamic apCurrency;
  dynamic appnamne;
  dynamic storename;
  dynamic phone_number;
  dynamic storeAddress;
  PDF.Document pdfInvoice;
  String invoicepath;
  ByteData imageData;
  
  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
      appnamne = prefs.getString('app_name');
      storename = prefs.getString('store_name');
      phone_number = prefs.getString('phone_number');
      storeAddress = prefs.getString('address');
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    var locale = AppLocalizations.of(context);
    if (!isEntered) {
      setState(() {
        isEntered = true;
        invoiceBeand = receivedData['inv_details'];
        createPdf(invoiceBeand);
      });
    }
    return (!isLoading && invoicepath != null && invoicepath.length > 0)
      ?
      PDFViewerScaffold(
        appBar: AppBar(
          title: Text(locale.invoiceNo +'${invoiceBeand.cart_id}'),
          actions: [
            IconButton(icon: Icon(Icons.print), onPressed: () { printPdf(context);  }),
            IconButton(icon: Icon(Icons.share), onPressed: () { sharePdf(context);  })
          ],
        ),
        path: invoicepath,
      )
      : Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Align(
              widthFactor: 50,
              heightFactor: 50,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }

  void createPdf(TodayOrderMain invoiceBean) async {
    rootBundle.load('assets/icon.png').then((data) => setState(() => this.imageData = data));
    PDF.Document pdf = PDF.Document();
    pdf.addPage(PDF.MultiPage(
      theme: PDF.ThemeData.withFont(
        base: PDF.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Regular.ttf")),
        bold: PDF.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Bold.ttf")),
        italic: PDF.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Italic.ttf")),
        boldItalic: PDF.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-BoldItalic.ttf")),
      ),
      pageFormat: PDFUTIL.PdfPageFormat.a4.copyWith(
        marginTop: 1.5 * PDFUTIL.PdfPageFormat.cm,
        marginRight: 1.5 * PDFUTIL.PdfPageFormat.cm,
        marginBottom: 1.5 * PDFUTIL.PdfPageFormat.cm,
        marginLeft: 1.5 * PDFUTIL.PdfPageFormat.cm),
      build: (PDF.Context cn) => [
        PDF.Container(
          alignment: PDF.Alignment.center,
          padding: PDF.EdgeInsets.only(bottom: 10),
          child: PDF.Text('$appnamne',style: PDF.TextStyle(fontSize: 20))),
        PDF.Padding(padding: const PDF.EdgeInsets.all(20)),
        PDF.Row(
          mainAxisAlignment: PDF.MainAxisAlignment.spaceBetween,
          children: [
            PDF.Container(
              width: MediaQuery.of(context).size.width * 0.35,
              child: PDF.Table.fromTextArray(
                  context: cn,
                  data: <List<String>>[
                    <String>['To'],
                    <String>['${invoiceBean.user_name}'],
                    <String>['${invoiceBean.user_phone}'],
                    <String>['${invoiceBean.user_address}'],
                  ],
                  border: PDF.TableBorder(
                    left: PDF.BorderSide.none,
                    top: PDF.BorderSide.none,
                    bottom: PDF.BorderSide.none,
                    right: PDF.BorderSide.none,
                    horizontalInside: PDF.BorderSide.none,
                    verticalInside: PDF.BorderSide.none,
                  ),
                  headerAlignment: PDF.Alignment.centerLeft,
                  cellAlignment: PDF.Alignment.centerLeft,
                  cellPadding: PDF.EdgeInsets.all(1)),
            ),
            PDF.Container(
              width: MediaQuery.of(context).size.width * 0.45,
              alignment: PDF.Alignment.center,
              // decoration: PDF.BoxDecoration(
              //   image: PDF.DecorationImage(
              //     image: AssetImage('')
              //   )
              // )
              child: PDF.Image(PDF.MemoryImage(imageData.buffer.asUint8List()),height: 100,width: 100)
            ),
        ]),
        PDF.Padding(padding: const PDF.EdgeInsets.all(10)),
        PDF.Row(
          mainAxisAlignment: PDF.MainAxisAlignment.spaceBetween,
            children: [
              PDF.Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: PDF.Table.fromTextArray(
                    context: cn,
                    data: <List<String>>[
                      <String>['From'],
                      <String>['$storename'],
                      <String>['$phone_number'],
                      <String>['$storeAddress}'],
                    ],
                    border: PDF.TableBorder(
                      left: PDF.BorderSide.none,
                      top: PDF.BorderSide.none,
                      bottom: PDF.BorderSide.none,
                      right: PDF.BorderSide.none,
                      horizontalInside: PDF.BorderSide.none,
                      verticalInside: PDF.BorderSide.none,
                    ),
                    headerAlignment: PDF.Alignment.centerLeft,
                    cellAlignment: PDF.Alignment.centerLeft,
                    cellPadding: PDF.EdgeInsets.all(1)),
              ),
              PDF.Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: PDF.Table.fromTextArray(
                    context: cn,
                    data: <List<String>>[
                      <String>[''],
                      <String>['INVOICE NO - #${invoiceBean.cart_id}'],
                      <String>['ORDER DATE - ${invoiceBean.order_details[0].order_date}'],
                      <String>['DELIVERY DATE - ${invoiceBean.delivery_date}'],
                    ],
                    border: PDF.TableBorder(
                      left: PDF.BorderSide.none,
                      top: PDF.BorderSide.none,
                      bottom: PDF.BorderSide.none,
                      right: PDF.BorderSide.none,
                      horizontalInside: PDF.BorderSide.none,
                      verticalInside: PDF.BorderSide.none,
                    ),
                    headerAlignment: PDF.Alignment.centerLeft,
                    cellAlignment: PDF.Alignment.centerLeft,
                    cellPadding: PDF.EdgeInsets.all(1)),
              ),
        ]),
        PDF.Padding(padding: const PDF.EdgeInsets.all(10)),
        PDF.Padding(padding: const PDF.EdgeInsets.all(10)),
        PDF.Table.fromTextArray(
          context: cn,
          data: createDataPdf(invoiceBean.order_details),
          border: PDF.TableBorder(
            left: PDF.BorderSide.none,
            top: PDF.BorderSide.none,
            bottom: PDF.BorderSide.none,
            right: PDF.BorderSide.none,
            horizontalInside: PDF.BorderSide(width: 1),
            verticalInside: PDF.BorderSide(width: 1)),
          cellAlignments: cellAlign()),
        PDF.Padding(padding: const PDF.EdgeInsets.all(10)),
        PDF.Padding(padding: const PDF.EdgeInsets.all(10)),
        PDF.Row(
          mainAxisAlignment: PDF.MainAxisAlignment.end,
          children: [
            PDF.Container(
              width: MediaQuery.of(context).size.width * 0.45,
              child: PDF.Table.fromTextArray(
                context: cn,
                data: <List<String>>[
                  <String>['', '', ''],
                  <String>['Sub Total', '->', ' $apCurrency. ${invoiceBean.order_price}'],
                  <String>['Delivery Charge', '->', ' $apCurrency. ${invoiceBean.delivery_charge}'],
                  <String>['Paid By Wallet', '->', ' $apCurrency. ${invoiceBean.paid_by_wallet}'],
                  <String>['Discount', '->', ' $apCurrency. ${invoiceBean.coupon_discount}'],
                  <String>['Total', '->', ' $apCurrency. ${(double.parse('${invoiceBean.order_price}') + double.parse('${invoiceBean.delivery_charge}'))}'],
                  <String>['Remaining Amount', '->', ' $apCurrency. ${invoiceBean.remaining_price}'],
                ],
                border: PDF.TableBorder(
                  left: PDF.BorderSide.none,
                  top: PDF.BorderSide.none,
                  bottom: PDF.BorderSide(width: 2),
                  right: PDF.BorderSide.none,
                  horizontalInside: PDF.BorderSide.none,
                  verticalInside: PDF.BorderSide.none,
                ),
                // headerDecoration: PDF.BoxDecoration(
                //   border: PDF.Border(top: PDF.BorderSide(width: 0))
                // ),
                rowDecoration: PDF.BoxDecoration(border: PDF.Border(top: PDF.BorderSide(width: 0))),
                headerAlignment: PDF.Alignment.centerLeft,
                cellAlignment: PDF.Alignment.centerLeft,
                cellPadding: PDF.EdgeInsets.all(1))),
         ]), // PDF.Table.fromTextArray(context: cn, data: ),
      ]));
    // pdf.save();
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/${invoiceBean.cart_id}.pdf';
    print('path 1 : '+path);
    final File file = File(path);
    pdf.save().then((value) {
      file.writeAsBytes(value).then((value) {
        setState(() {
          invoicepath = value.path;
          pdfInvoice = pdf;
          isLoading = false;
        });
      }).catchError((e) {
        print('createPdf ERROR 1 : $e');
        setState(() { isLoading = false;   });
      });
      print('path 2 : '+path);
    }).catchError((e) {
      print('createPdf ERROR 2 : $e');
      setState(() {  isLoading = false;  });
      print('path 3 : '+path);
    });
  }

  dynamic cellAlign() {
    Map<int, PDF.Alignment> align = {
      0: PDF.Alignment.center,
      1: PDF.Alignment.centerLeft,
      2: PDF.Alignment.center,
      3: PDF.Alignment.center,
      4: PDF.Alignment.center,
    };
    return align;
  }

  dynamic createDataPdf(List<TodayOrderItems> data) {
    List<List<String>> vdar = [];
    List<String> dd1 = [];
    for (int j = 0; j < 5; j++) {
      if (j == 0) { dd1.add('#.');  }
      else if (j == 1) {  dd1.add('Item Description');  }
      else if (j == 2) {  dd1.add('Qnty.'); }
      else if (j == 3) {  dd1.add('Price'); }
      else if (j == 4) {  dd1.add('Total Price');  }
    }
    vdar.add(dd1);
    for (int i = 0; i < data.length; i++) {
      List<String> dd = [];
      for (int j = 0; j < 5; j++) {
        if (j == 0) { dd.add('${i + 1}'); }
        else if (j == 1) {  dd.add('${data[i].product_name} (${data[i].quantity}${data[i].unit})'); }
        else if (j == 2) {  dd.add('${data[i].qty}');  }
        else if (j == 3) {  dd.add('${(double.parse('${data[i].price}') / int.parse('${data[i].qty}'))}');  }
        else if (j == 4) {  dd.add('${data[i].price}'); }
      }
      vdar.add(dd);
    }
    return vdar;
  }

  void printPdf(BuildContext context) async {
    Printing.pickPrinter(context: context).then((value){
      if(value!=null && value.isAvailable){
        Printing.directPrintPdf(printer: value, onLayout: (format) => pdfInvoice.save(),);
      }else{
        var format = PDFUTIL.PdfPageFormat.a4;

        Printing.layoutPdf(
          onLayout: (format) => pdfInvoice.save(),
          name: File(invoicepath).path.split('/').last,
          format: format,
        );
      }
    }).catchError((e){
      print('printPdf ERROR : ${e.toString()}');
      Toast.show(e.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      var format = PDFUTIL.PdfPageFormat.a4;
      Printing.layoutPdf(
        onLayout: (format) => pdfInvoice.save(),
        name: File(invoicepath).path.split('/').last,
        format: format,
      );
    });
  }

  void sharePdf(context) async {
    Printing.sharePdf(bytes: await pdfInvoice.save(), filename: File(invoicepath).path.split('/').last);
  }

// <String>['2000', 'Ipsum 1.0', 'Lorem 1'],
// <String>['2001', 'Ipsum 1.1', 'Lorem 2'],
// <String>['2002', 'Ipsum 1.2', 'Lorem 3'],
// <String>['2003', 'Ipsum 1.3', 'Lorem 4'],
// <String>['2004', 'Ipsum 1.4', 'Lorem 5'],
// <String>['2004', 'Ipsum 1.5', 'Lorem 6'],
// <String>['2006', 'Ipsum 1.6', 'Lorem 7'],
// <String>['2007', 'Ipsum 1.7', 'Lorem 8'],
// <String>['2008', 'Ipsum 1.7', 'Lorem 9'],

}
