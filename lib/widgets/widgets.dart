import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ldk_node/ldk_node.dart' as ldk;

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SubmitButton({Key? key, required this.text, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        width: double.infinity,
        child: Center(
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontSize: 14, color: Colors.white)),
        ),
      ),
    );
  }
}

popUpWidget(
    {required String title,
    required SizedBox widget,
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

AppBar buildAppBar(
    BuildContext context, void Function() startNode, void Function() syncNode) {
  return AppBar(
    leadingWidth: 100,
    backgroundColor: Colors.white,
    elevation: 0,
    actions: [
      IconButton(
          onPressed: startNode,
          icon: Icon(
            CupertinoIcons.power,
            size: 20,
            color: Theme.of(context).secondaryHeaderColor,
          )),
      IconButton(
          onPressed: syncNode,
          icon: Icon(
            CupertinoIcons.refresh,
            size: 20,
            color: Theme.of(context).secondaryHeaderColor,
          ))
    ],
    leading: Icon(
      CupertinoIcons.bolt_circle,
      color: Theme.of(context).secondaryHeaderColor,
      size: 30,
    ),
    title: Text("Ldk Node Flutter Quickstart",
        style: Theme.of(context)
            .textTheme
            .displaySmall!
            .copyWith(fontWeight: FontWeight.w800)),
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
          color: Colors.indigoAccent.withOpacity(.25),
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
  const BalanceWidget({Key? key, required this.balance, required this.nodeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
            color: Colors.indigoAccent.withOpacity(.25),
            border: Border.all(
              width: 2,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${balance / 100000000} BTC",
                maxLines: 3,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w900)),
            SelectableText(
              nodeId == null ? "Node not initialized" : "@Id_:$nodeId",
              maxLines: 3,
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(color: Colors.black54),
            ),
          ],
        ));
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
                decoration: const InputDecoration(labelText: 'Mnemonic'),
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
  final Future<void> Function(String host, int port, String nodeId, int amount)
      openChannelCallBack;
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
        IconButton(
            onPressed: () {
              popUpWidget(
                context: context,
                title: 'Open channel',
                widget: SizedBox(
                  height: 290,
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
                          decoration:
                              const InputDecoration(labelText: 'Node Id'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the nodePubKeyAndAddress ';
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
                                decoration: const InputDecoration(
                                    labelText: 'Ip Address'),
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
                                decoration:
                                    const InputDecoration(labelText: 'Port'),
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
                          decoration:
                              const InputDecoration(labelText: 'Amount'),
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
                        const SizedBox(height: 30),
                        SubmitButton(
                          text: 'Submit',
                          callback: () async {
                            if (_formKey.currentState!.validate()) {
                              await widget.openChannelCallBack(
                                  address, port, nodeId, amount);
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
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.black,
            )),
      ],
    );
  }
}

class ChannelListWidget extends StatefulWidget {
  final List<ldk.ChannelDetails> channels;
  final Future<void> Function(ldk.ChannelId channelId, String nodeId)
      closeChannelCallBack;
  final Future<String> Function(int amount) receivePaymentCallBack;
  final Future<void> Function(String invoice) sendPaymentCallBack;
  const ChannelListWidget(
      {Key? key,
      required this.channels,
      required this.closeChannelCallBack,
      required this.receivePaymentCallBack,
      required this.sendPaymentCallBack})
      : super(key: key);

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
    return ListView.builder(
        itemCount: widget.channels.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => ListTile(
            leading: Column(
              children: [
                Icon(
                  (widget.channels[index].isUsable &&
                          widget.channels[index].isChannelReady)
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.timer_fill,
                  color: Colors.black,
                  size: 25,
                ),
                const SizedBox(
                  height: 5,
                ),
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
            title: Text(
              widget.channels[index].channelId.internal
                  .map((e) => e.toRadixString(16))
                  .toList()
                  .join()
                  .toString(),
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
                '${widget.channels[index].outboundCapacityMsat} SATS',
                overflow: TextOverflow.clip,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black.withOpacity(.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            trailing: PopupMenuButton(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text(
                        "Receive",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text(
                        "Send",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text(
                        "Close Channel",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    popUpWidget(
                      context: context,
                      title: 'Receive',
                      widget: SizedBox(
                        height: 120,
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
                                decoration:
                                    const InputDecoration(labelText: 'Amount'),
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
                              const SizedBox(
                                height: 5,
                              ),
                              SubmitButton(
                                text: 'Receive',
                                callback: () async {
                                  if (_receiveKey.currentState!.validate()) {
                                    await widget.receivePaymentCallBack(amount);
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
                                decoration:
                                    const InputDecoration(labelText: 'Invoice'),
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
                                    await widget.sendPaymentCallBack(invoice);
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
                                decoration: const InputDecoration(
                                    labelText: 'Counterparty Node Id'),
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
                                        widget.channels[index].channelId,
                                        address);
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
                })));
  }
}
