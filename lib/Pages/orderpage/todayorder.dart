import 'dart:convert';
import 'dart:typed_data';
// import 'package:bluetoothonoff/bluetoothonoff.dart';
import 'package:bluetooth_enable/bluetooth_enable.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as childImage;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Pages/Other/order_info.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/orderbean/todayorderbean.dart';
import 'package:vendor/beanmodel/util/invoice.dart';

class TodayOrder extends StatefulWidget {
  @override
  _TodayOrderState createState() => _TodayOrderState();
}

class _TodayOrderState extends State<TodayOrder> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  bool _connected = false;
  String tips = 'no device connect';
  List<TodayOrderMain> newOrders = [];
  bool isLoading = false;
  bool isVisible = false;
  var http = Client();
  dynamic apCurrency;

  PrinterBluetooth connectedDevice;

  dynamic cartId;

  void blueInit(BuildContext context, AppLocalizations locale, cartId) async {
    setState(() {
      this.cartId = cartId;
    });
    if (connectedDevice != null) {
      getInvoice(cartId, locale);
    } else {
      BluetoothEnable.enableBluetooth.then((value){
        print('blueInit => on $value');
          setState(() {
            isVisible = true;
          });
        // if (result == "true"){
        //   //Bluetooth has been enabled
        // }
        // else if (result == "false") {
        //   //Bluetooth has not been enabled
        // }
      });
      // BluetoothOnOff.turnOnBluetooth.then((value) {
      //   print('on $value');
      //   setState(() {
      //     isVisible = true;
      //   });
      // });
    }
  }

  @override
  void initState() {
    super.initState();
    printerManager.scanResults.listen((devices) async {
      if(devices.length>0){
        print('devices length - ${devices.length}');
        setState(() {
          isVisible = true;
          _devices = devices;
        });
      }
    });
    getOrderList();
  }

  @override
  void dispose() {
    _stopScanDevices();
    http.close();
    super.dispose();
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 30));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  void getOrderList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('store_id');
    setState(() {
      isLoading = true;
      apCurrency = prefs.getString('app_currency');
    });
    print('getOrderList => storetodayOrdersUri : $storetodayOrdersUri store_id  $id');
    http.post(storetodayOrdersUri,
        body: {'store_id': '${prefs.getInt('store_id')}'}).then((value) {
      print('getOrderList => value.body : ${value.body.toString()}');
      if (value.statusCode == 200) {
        if ('${value.body}' != '[{\"order_details\":\"no orders found\"}]') {
          var jsD = jsonDecode(value.body) as List;
          setState(() {
            newOrders.clear();
            newOrders = List.from(jsD.map((e) => TodayOrderMain.fromJson(e)).toList());
          });
        } else {
          setState(() {  newOrders.clear();  });
        }
      } else {
        setState(() {  newOrders.clear();   });
      }
      setState(() { isLoading = false;  });
    }).catchError((e) {
      print('getOrderList EEROR : ${e.toString()}');
      setState(() {
        isLoading = false;
        newOrders.clear();
      });
      print('getOrderList => ERROR : ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    print('Today Order SCREEN');

    return Stack(
      children: [
        Visibility(child: (isVisible && _devices != null && _devices.length > 0)
          ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: kWhiteColor,
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (BuildContext context, int index) {
                return buildBluetoothCard(context, _devices[index], locale);
              }
            ),
           )
          : SizedBox.shrink(),
        ),
        Container(
          color: kWhiteColor,
          child: (!isLoading && newOrders != null && newOrders.length > 0)
            ? ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: 20),
                    physics: ScrollPhysics(),
                    itemCount: newOrders.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return buildCompleteCard(context, newOrders[index]);
                    }),
                ],
              )
            : isLoading
            ? Align(
                widthFactor: 40,
                heightFactor: 40,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Align(
                alignment: Alignment.center,
                child: Text(locale.noorderfnd,style: TextStyle(
                  color: kMainTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
             ),
        ),
      ],
    );
  }

  CircleAvatar buildStatusIcon(IconData icon, {bool disabled = false}) =>
      CircleAvatar(
        backgroundColor: !disabled ? Color(0xff222e3e) : Colors.grey[300],
        child: Icon(icon, size: 20,
          color: !disabled ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor));

  GestureDetector buildCompleteCard(BuildContext context, TodayOrderMain mainP) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderInfo(mainP)));
      },
      child: Card(
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        margin: EdgeInsets.only(left: 14, right: 14, top: 14),
        color: Colors.white,
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildItem(context, mainP),
            Container(width:MediaQuery.of(context).size.width-75,height: 1,color: kBorderColor,),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildOrderInfoRow(context, '$apCurrency ${mainP.order_price}', '${mainP.payment_mode}', '${mainP.order_status}'),
                  Row(
                    children: [
                      buildPrintInvoice(context, locale, cartId: '${mainP.cart_id}',orderMain: mainP),
                      SizedBox(width: 10),
                      StreamBuilder<bool>(
                        stream: printerManager.isScanningStream,
                        initialData: false,
                        builder: (c, snapshot) {
                          if (snapshot.data || connectedDevice!=null) {
                            return buildPrintRow(context, locale, cartId: '${mainP.cart_id}');
                          } else {
                            return buildSearchRow(context, locale, cartId: '${mainP.cart_id}');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildOrderInfoRow(BuildContext context, String price, String prodID,
      String orderStatus,
      {double borderRadius = 8}) {
    var locale = AppLocalizations.of(context);
    return Container(
      width:MediaQuery.of(context).size.width*0.65,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
        color: kWhiteColor,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildGreyColumn(context, locale.payment, price,text2Color: kMainPriceText),
          buildGreyColumn(context, locale.paymentmode, prodID,text2Color: kMainPriceText),
          buildGreyColumn(context, locale.orderStatus, orderStatus, text2Color:kMainPriceText),
        ],
      ),
    );
  }

  GestureDetector buildPrintRow(BuildContext context, AppLocalizations locale,
      {double borderRadius = 8, dynamic cartId}) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: (){
        if(_devices!=null && _devices.length>0){
          blueInit(context, locale, cartId);
        }else{
          Toast.show(locale.bluetoothOnMessage, context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
        }
      },
      child: Container(
        height: 30,
        width: 30,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: kWhiteColor,
          border: Border.all(color: kRoundButtonInButton, width: 1),
        ),
        // padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 12),
        child: Image.asset('assets/Icon_printer.png'),

      ),
    );
  }

  GestureDetector buildPrintInvoice(BuildContext context, AppLocalizations locale,
      {double borderRadius = 8, dynamic cartId, TodayOrderMain orderMain}) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed(PageRoutes.invoice, arguments: {'inv_details': orderMain}).then((value) {}).catchError((e) {
          print('buildPrintInvoice => ERROR : ${e.toString()}');
        });
      },
      child: Container(
        height: 30,
        width: 30,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: kRoundButtonInButton),
        // padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 12),
        child: Image.asset('assets/Icon_pdf.png'),
      ),
    );
  }

  GestureDetector buildSearchRow(BuildContext context, AppLocalizations locale,
      {double borderRadius = 8, dynamic cartId}) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: (){
        _startScanDevices();
      },
      child: Container(
        height: 30,
        width: 30,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: kWhiteColor, border: Border.all(color: kRoundButtonInButton, width: 1)),
        // padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 12),
        child: Image.asset('assets/Icon_printer.png'),
      ),
    );
  }

  void getInvoice(dynamic cartId, AppLocalizations locale) async {
    printerManager.selectPrinter(connectedDevice);
    const PaperSize paper = PaperSize.mm80;
    print('getInvoice => getInvoiceUri : $getInvoiceUri '+ 'cart_id ' + '$cartId');

    http.post(getInvoiceUri, body: {'cart_id': cartId}).then((value) {
      if (value.statusCode == 200) {
        Invoice invoice = Invoice.fromJson(jsonDecode(value.body));
        print('getInvoice => invoice : $invoice');
        if ('${invoice.status}' == '1') {
          printOrCreateInvoice(invoice, locale).then((pTicket) async {
            printerManager.printTicket(pTicket).then((value) {
              setState(() {
                if (isVisible) {  isVisible = false;  }
              });
            });
          });
        }
      }
      setState(() {
        if (isVisible) {
          isVisible = false;
        }
      });
    }).catchError((e) {
      print('getInvoice => ERROR : $e');
      setState(() {
        if (isVisible) {
          isVisible = false;
        }
      });
    });
  }

  Future<Ticket> printOrCreateInvoice(Invoice invoice, AppLocalizations locale) async {
    final Ticket ticket = Ticket(PaperSize.mm80);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ByteData data = await rootBundle.load('assets/icon.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final childImage.Image image = childImage.decodeImage(bytes);
    ticket.image(image);
    ticket.text(prefs.getString('app_name'), styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2), linesAfter: 1);
    ticket.text('${invoice.address}', styles: PosStyles(align: PosAlign.center));
    ticket.text('${invoice.city} (${invoice.pincode})', styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel: ${invoice.number}', styles: PosStyles(align: PosAlign.center));
    ticket.hr();
    ticket.row([
      PosColumn(text: '#', width: 1),
      PosColumn(text: locale.invoice1h, width: 7),
      PosColumn(text: locale.invoice2h, width: 1),
      PosColumn(text: locale.invoice3h, width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: locale.invoice4h, width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    List<OrderDetails> orderDetaisl = List.from(invoice.orderDetails);
    int it = 1;
    for (OrderDetails details in orderDetaisl) {
      ticket.row([
        PosColumn(text: '$it', width: 1),
        PosColumn(text: '${details.productName} (${details.quantity} ${details.unit})', width: 7),
        PosColumn(text: '${details.qty}', width: 1),
        PosColumn(text: '${details.price}', width: 2, styles: PosStyles(align: PosAlign.right)),
        PosColumn(text: '${double.parse('${details.price}') * double.parse('${details.qty}')}', width: 2, styles: PosStyles(align: PosAlign.right)),
      ]);
      it++;
    }

    ticket.hr();

    ticket.row([
      PosColumn(text: locale.invoice4h, width: 6, styles: PosStyles(height: PosTextSize.size2, width: PosTextSize.size2)),
      PosColumn(text: '$apCurrency ${double.parse('${invoice.totalPrice}') + double.parse('${invoice.deliveryCharge}')}', width: 6, styles: PosStyles(align: PosAlign.right, height: PosTextSize.size2, width: PosTextSize.size2)),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);
    ticket.row([
      PosColumn(text: locale.invoice5h, width: 7, styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(text: '$apCurrency ${invoice.totalPrice}', width: 5, styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    ticket.row([
      PosColumn(text: locale.invoice6h, width: 7, styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(text: '$apCurrency ${invoice.deliveryCharge}', width: 5, styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    ticket.feed(2);
    ticket.text(locale.invoice7h, styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp, styles: PosStyles(align: PosAlign.center), linesAfter: 2);
    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  Padding buildItem(BuildContext context, TodayOrderMain mainP) {
    var locale = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(mainP.user_name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.subtitle1.copyWith(color: kTextBlack,fontSize: 16,fontWeight: FontWeight.w700),),
                        // SizedBox(width: 5),
                        Flexible(child: Text(' - '+mainP.user_phone, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.subtitle1.copyWith(color: kTextBlack,fontSize: 16,fontWeight: FontWeight.w700)))
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(mainP.user_address, maxLines: 2, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12,color: kSearchIconColour)),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(width: 15),
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(mainP.order_details[0].varient_image, height: 70,width: 70,fit: BoxFit.cover,)),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: kRoundButtonInButton2, borderRadius: BorderRadius.circular(45)),
                child: Text(
                  locale.orderID + ' #${mainP.cart_id}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12,color: kOrderIdColor,fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 10),
              Flexible(child: Text(locale.orderedOn + ' : ${mainP.order_details[0].order_date}', overflow: TextOverflow.fade, textAlign: TextAlign.center, maxLines: 2, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 12,color: kTextBlack,fontWeight: FontWeight.normal)),),
            ],
          ),
        ],
      ),
    );
  }

  Padding buildAmountRow(String name, String price,
      {FontWeight fontWeight = FontWeight.w500}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Text(name, style: TextStyle(fontWeight: fontWeight)),
          Spacer(),
          Text(price, style: TextStyle(fontWeight: fontWeight)),
        ],
      ),
    );
  }

  Column buildGreyColumn(BuildContext context, String text1, String text2,
      {Color text2Color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text1, style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 10,color: kTextBlack,)),
        SizedBox(height: 8),
        LimitedBox(
          maxWidth: 100,
          child: Text(text2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: text2Color)),
        ),
      ],
    );
  }

  Container buildBluetoothCard(BuildContext context, PrinterBluetooth bt,
      AppLocalizations locale) {
    var locale = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Icon(Icons.bluetooth_audio_sharp)),
              SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.subtitle1,
                  children: <TextSpan>[
                    TextSpan(text: '${bt.name}\n'),
                    TextSpan(text: '${locale.apparel}\n\n', style: Theme.of(context).textTheme.subtitle2),
                    TextSpan(text: '${bt.address} ${locale.sold}', style: Theme.of(context).textTheme.bodyText2.copyWith(height: 0.5)),
                  ])),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    connectedDevice = bt;
                    getInvoice(cartId, locale);
                  });
                },
                child: Text(locale.connect),
                color: kMainColor,
                textColor: kWhiteColor,),
            ),
          ),
        ],
      ),
    );
  }


}
