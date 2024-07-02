// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:ldk_node_flutter_demo/styles/theme.dart';

int satsToMsats(int sats) => sats * 1000;
String mSatsToSats(int mSats) => '${mSats ~/ 1000}sats';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SubmitButton({Key? key, required this.text, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          elevation: 3,
          shadowColor: AppColors.blue,
          backgroundColor: AppColors.blue,
          padding: EdgeInsets.all(17),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        child: Center(
          child: Text(text,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final VoidCallback callback;

  const SmallButton({
    Key? key,
    required this.text,
    required this.callback,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: !disabled ? callback : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10),
        minimumSize: Size(80, 30),
        backgroundColor: Color(0xFFFD7E14),
        foregroundColor: disabled ? Colors.grey : Colors.black,
        //  side: BorderSide(width: 1.0, color: AppColors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 5,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

popUpWidget(
    {required String title,
    required Widget widget,
    required BuildContext context}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(right: 20, left: 20, bottom: 30),
          titlePadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(fontSize: 16, height: 3, fontWeight: FontWeight.w800),
          ),
          content: widget,
        );
      });
}

PreferredSize buildAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: Size.fromHeight(50), // Set this height
    child: Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 59, 32, 133),
              border: Border.all(color: AppColors.blue, width: 1),
              borderRadius: BorderRadius.circular(
                  25.0), // Make sure to adjust this so it fits nicely within the outer container
            ),
            child: Image.asset("assets/flutter-logo.png"),
          ),
          Spacer(),
          Text(
            'Demo App \n Ldk Node Flutter',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Spacer(),
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/ldk-logo.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ],
      ),
    ),
  );
}

class ResponseContainer extends StatelessWidget {
  final String text;

  const ResponseContainer({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        child: StyledContainer(
          child: SelectableText.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: "Response: ",
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.w900)),
                TextSpan(
                    text: text,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        )); // Your widget tree
  }
}

class StyledContainer extends StatelessWidget {
  final Widget child;

  const StyledContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
          color: AppColors.blue.withOpacity(.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: Theme.of(context).secondaryHeaderColor,
          )),
      child: child,
    );
  }
}

class BalanceWidget extends StatelessWidget {
  final int balance;
  final String nodeId;
  final String listeningAddress;
  final String fundingAddress;
  const BalanceWidget(
      {Key? key,
      required this.balance,
      required this.nodeId,
      required this.listeningAddress,
      required this.fundingAddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightOrange,
          border: Border.all(
            width: 2,
            color: AppColors.blue,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 12.0, // soften the shadow
              // spreadRadius: 1.0, //extend the shadow
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text("${balance / 100000000} BTC",
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 25,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w900)),
              ),
              BoxRow(title: "Listening Address", value: listeningAddress),
              BoxRow(title: "Node Id", value: nodeId),
              BoxRow(title: "Funding Address", value: fundingAddress),
            ],
          ),
        ));
  }
}

class BoxRow extends StatelessWidget {
  const BoxRow(
      {super.key,
      required this.title,
      required this.value,
      this.color = Colors.black});

  final String title;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SelectableText.rich(
        TextSpan(
          style: TextStyle(fontSize: 12.0, color: color),
          children: [
            TextSpan(
              text: "$title: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class MnemonicWidget extends StatefulWidget {
  final Function(String e) buildCallBack;
  const MnemonicWidget({Key? key, required this.buildCallBack})
      : super(key: key);

  @override
  State<MnemonicWidget> createState() => _MnemonicWidgetState();
}

class _MnemonicWidgetState extends State<MnemonicWidget> {
  String? aliceMnemonic;
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Column(
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter Mnemonic",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(20),
                child: TextFormField(
                  maxLines: 6,
                  showCursor: true,
                  autofocus: true,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Mnemonic',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: AppColors.lightOrange,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.blue, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid mnemonic';
                    }
                    setState(() {
                      aliceMnemonic = value;
                    });
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              SubmitButton(
                text: 'Start Node',
                callback: () async {
                  if (formKey.currentState!.validate() &&
                      aliceMnemonic != null) {
                    await widget.buildCallBack(aliceMnemonic!);
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ChannelsActionBar extends StatefulWidget {
  final Future<void> Function(String host, int port, String nodeId, int amount,
      int pushToCounterpartyMsat) openChannelCallBack;
  const ChannelsActionBar({Key? key, required this.openChannelCallBack})
      : super(key: key);

  @override
  State<ChannelsActionBar> createState() => _ChannelsActionBarState();
}

class _ChannelsActionBarState extends State<ChannelsActionBar> {
  final _formKey = GlobalKey<FormState>();
  String address = "";
  int port = 0;
  String nodeId = "";
  int amount = 0;
  int counterPartyAmount = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Channels',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontWeight: FontWeight.w800),
        ),
        SmallButton(
            text: "+ Channel",
            callback: () {
              _channelPopup(context);
            })
      ],
    );
  }

  _channelPopup(BuildContext context) {
    popUpWidget(
      context: context,
      title: 'Open channel',
      widget: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                showCursor: true,
                autofocus: true,
                style: TextStyle(
                    color: Colors.black.withOpacity(.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(labelText: 'Node Id'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the nodeId ';
                  }
                  setState(() {
                    nodeId = value;
                  });
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      showCursor: true,
                      autofocus: true,
                      style: TextStyle(
                          color: Colors.black.withOpacity(.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      decoration:
                          const InputDecoration(labelText: 'Ip Address'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ip Address';
                        }
                        setState(() {
                          address = value;
                        });
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      showCursor: true,
                      autofocus: true,
                      style: TextStyle(
                          color: Colors.black.withOpacity(.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(labelText: 'Port'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your port number ';
                        }
                        setState(() {
                          port = int.parse(value.trim());
                        });
                        return null;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(
                    color: Colors.black.withOpacity(.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Amount';
                  }
                  setState(() {
                    amount = int.parse(value.trim());
                  });
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(
                    color: Colors.black.withOpacity(.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                    labelText: 'CounterPartyAmount in sats'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the counterPartyAmount';
                  }
                  setState(() {
                    counterPartyAmount = int.parse(value.trim());
                  });
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SubmitButton(
                text: 'Submit',
                callback: () async {
                  if (_formKey.currentState!.validate()) {
                    await widget.openChannelCallBack(
                        address, port, nodeId, amount, counterPartyAmount);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChannelListWidget extends StatefulWidget {
  final List<ldk.ChannelDetails> channels;
  final Future<void> Function(ldk.UserChannelId channelId, ldk.PublicKey nodeId)
      closeChannelCallBack;
  final Future<String> Function(
    int amount, {
    bool requestJitChannel,
  }) receivePaymentCallBack;
  final Future<String> Function(String invoice) sendPaymentCallBack;
  const ChannelListWidget({
    Key? key,
    required this.channels,
    required this.closeChannelCallBack,
    required this.receivePaymentCallBack,
    required this.sendPaymentCallBack,
  }) : super(key: key);

  @override
  State<ChannelListWidget> createState() => _ChannelListWidgetState();
}

class _ChannelListWidgetState extends State<ChannelListWidget> {
  int amount = 0;
  String address = "";
  final _receiveKey = GlobalKey<FormState>();
  final _sendKey = GlobalKey<FormState>();
  String invoice = "";

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemCount: widget.channels.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) => channelListItem(index, context));
  }

  ListTile channelListItem(int index, BuildContext context) {
    final isReady = widget.channels[index].isUsable &&
        widget.channels[index].isChannelReady;
    var borderRadius = BorderRadius.all(Radius.circular(12));
    return ListTile(
      tileColor: index % 2 == 0 ? Colors.grey.shade100 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      contentPadding: EdgeInsets.all(12),
      title: _buildTitle(isReady, index),
      subtitle: _buildSubtitle(isReady, index),
    );
  }

  Row _buildTitle(isReady, index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            children: [
              Image.asset(
                isReady ? "assets/complete.png" : "assets/waiting.png",
                width: 25,
                color: isReady ? Colors.green : Colors.grey,
              ),
              SizedBox(height: 5),
              Text(
                  '${widget.channels[index].confirmations} / ${widget.channels[index].confirmationsRequired!}',
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w500))
            ],
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Flexible(
          flex: 5,
          child: Text(
            widget.channels[index].channelId.data
                .map((e) => e.toRadixString(16))
                .toList()
                .join()
                .toString(),
            overflow: TextOverflow.clip,
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Column _buildSubtitle(isReady, index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxRow(
              title: "Capacity",
              value: '${widget.channels[index].channelValueSats}sats',
              color: AppColors.blue,
            ),
            BoxRow(
              title: "Local Balance",
              value: mSatsToSats(widget.channels[index].outboundCapacityMsat),
              color: Colors.green,
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxRow(
              title: "Inbound",
              value: mSatsToSats(widget.channels[index].inboundCapacityMsat),
              color: Colors.green,
            ),
            BoxRow(
              title: "Outbound",
              value: mSatsToSats(widget.channels[index].outboundCapacityMsat),
              color: Colors.red,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmallButton(
              text: "Send",
              callback: () => {buttonPopup(context, 1, index)},
              disabled: !isReady,
            ),
            SmallButton(
              text: "Receive",
              callback: () => {buttonPopup(context, 0, index)},
              disabled: !isReady,
            ),
            SmallButton(
              text: "Close",
              callback: () => {buttonPopup(context, 2, index)},
              disabled: !isReady,
            ),
          ],
        ),
      ],
    );
  }

  getInvoice() async {}
  buttonPopup(BuildContext context, value, index) {
    if (value == 0) {
      popUpWidget(
        context: context,
        title: 'Receive',
        widget: ReceivePopupWidget(
          receivePaymentCallBack: widget.receivePaymentCallBack,
          requestJitChannel: false,
        ),
      );
    } else if (value == 1) {
      popUpWidget(
        context: context,
        title: 'Send',
        widget: SizedBox(
          height: 140,
          child: Form(
            key: _sendKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(labelText: 'Invoice'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Invoice';
                    }
                    setState(() {
                      invoice = value;
                    });
                    return null;
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                SubmitButton(
                  text: 'Send',
                  callback: () async {
                    if (_sendKey.currentState!.validate()) {
                      String status = await widget.sendPaymentCallBack(invoice);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      popUpWidget(
                        context: context,
                        title: "Send Status",
                        widget: SelectableText('Status: $status'),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      );
    } else if (value == 2) {
      widget.closeChannelCallBack(widget.channels[index].userChannelId,
          widget.channels[index].counterpartyNodeId);
    }
  }
}

class ReceivePopupWidget extends StatefulWidget {
  final Future<String> Function(
    int amount, {
    bool requestJitChannel,
  }) receivePaymentCallBack;
  final bool requestJitChannel;

  const ReceivePopupWidget({
    Key? key,
    required this.receivePaymentCallBack,
    this.requestJitChannel = false,
  }) : super(key: key);

  @override
  State<ReceivePopupWidget> createState() => _ReceivePopupWidgetState();
}

class _ReceivePopupWidgetState extends State<ReceivePopupWidget> {
  final _formKey = GlobalKey<FormState>();
  int amount = 0;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      // height: 200,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              style: TextStyle(
                  color: Colors.black.withOpacity(.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
              decoration: const InputDecoration(labelText: 'Amount in sats'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the Amount';
                }
                setState(() {
                  amount = int.parse(value);
                });
                return null;
              },
            ),
            const SizedBox(height: 5),
            SubmitButton(
              text: 'Receive',
              callback: () async {
                if (_formKey.currentState!.validate()) {
                  String invoiceText = await widget.receivePaymentCallBack(
                    amount,
                    requestJitChannel: widget.requestJitChannel,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  popUpWidget(
                    context: context,
                    title: "Invoice",
                    widget: SelectableText(invoiceText),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
