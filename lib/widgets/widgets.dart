// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:ldk_node_flutter_quickstart/styles/theme.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SubmitButton({Key? key, required this.text, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          padding: EdgeInsets.all(17),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        child: Center(
          child: Text(text),
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
        side: BorderSide(width: 1.0, color: AppColors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 2,
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
    preferredSize: Size.fromHeight(40), // Set this height
    child: Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.blue, width: 1),
              ),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Image.asset("assets/flutter-logo.png",
                    width: 30, height: 30),
              )),
          Spacer(),
          Text(
            'Demo App \n Ldk Node Flutter',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Image.asset("assets/logo.png"),
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
        ));
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
        height: 130,
        decoration: BoxDecoration(
            color: AppColors.lightOrange,
            border: Border.all(
              width: 2,
              color: AppColors.blue,
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${balance / 100000000} BTC",
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 25,
                    color: AppColors.blue,
                    fontWeight: FontWeight.w900)),
            BoxRow(title: "Listening Address", value: listeningAddress),
            BoxRow(title: "Node Id", value: nodeId),
            BoxRow(title: "Funding Address", value: fundingAddress),
          ],
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
    return SelectableText.rich(
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
    final _formKey = GlobalKey<FormState>();
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                maxLines: 8,
                showCursor: true,
                autofocus: true,
                style: TextStyle(
                    color: Colors.black.withOpacity(.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                    labelText: 'Mnemonic', fillColor: AppColors.lightOrange),
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
              const SizedBox(height: 10),
              SubmitButton(
                text: 'Build Node',
                callback: () async {
                  if (_formKey.currentState!.validate() &&
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
      widget: SizedBox(
        height: 380,
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
                decoration:
                    const InputDecoration(labelText: 'CounterPartyAmount'),
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
  final Future<void> Function(ldk.ChannelId channelId, String nodeId)
      closeChannelCallBack;
  final Future<String> Function(int amount) receivePaymentCallBack;
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
  final _closeKey = GlobalKey<FormState>();
  String invoice = "";

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemCount: widget.channels.length,
        shrinkWrap: true,
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
      contentPadding: EdgeInsets.all(7),
      leading: Column(
        children: [
          Image.asset(
            isReady ? "assets/complete.png" : "assets/waiting.png",
            width: 25,
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
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          widget.channels[index].channelId.internal
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
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 4.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BoxRow(
                  title: "Capacity",
                  value: '${widget.channels[index].channelValueSats}',
                  color: AppColors.blue,
                ),
                BoxRow(
                  title: "Local Balance",
                  value: '${widget.channels[index].balanceMsat}',
                  color: Colors.green,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BoxRow(
                  title: "Inbound",
                  value: '${widget.channels[index].inboundCapacityMsat}',
                  color: Colors.green,
                ),
                BoxRow(
                  title: "     Outbound",
                  value: '${widget.channels[index].outboundCapacityMsat}',
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
        ),
      ),
    );
  }

  getInvoice() async {}
  buttonPopup(BuildContext context, value, index) {
    if (value == 0) {
      popUpWidget(
        context: context,
        title: 'Receive',
        widget: IntrinsicHeight(
          // height: 200,
          child: Form(
            key: _receiveKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                      amount = int.parse(value);
                    });
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                SubmitButton(
                  text: 'Receive',
                  callback: () async {
                    if (_receiveKey.currentState!.validate()) {
                      String invoiceText =
                          await widget.receivePaymentCallBack(amount);
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
        ),
      );
    } else if (value == 1) {
      popUpWidget(
        context: context,
        title: 'Send',
        widget: SizedBox(
          height: 120,
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
                  text: 'Submit',
                  callback: () async {
                    if (_sendKey.currentState!.validate()) {
                      String status = await widget.sendPaymentCallBack(invoice);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      popUpWidget(
                        context: context,
                        title: "Send Status",
                        widget: SelectableText(status),
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
      popUpWidget(
        context: context,
        title: 'Close channel',
        widget: SizedBox(
          height: 120,
          child: Form(
            key: _closeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  decoration:
                      const InputDecoration(labelText: 'Counterparty Node Id'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Counterparty Node Id';
                    }
                    setState(() {
                      address = value;
                    });
                    return null;
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                SubmitButton(
                  text: 'Submit',
                  callback: () async {
                    if (_closeKey.currentState!.validate()) {
                      await widget.closeChannelCallBack(
                          widget.channels[index].channelId, address);
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
}
