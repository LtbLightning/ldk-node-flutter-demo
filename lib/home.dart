import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ldk_node_flutter/ldk_node_flutter.dart' as ldk;
import 'package:ldk_node_flutter_quickstart/widgets.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ldk.Node aliceNode;
  ldk.PublicKey? aliceNodeId;
  int aliceBalance = 0;
  String displayText = "";
  String? invoice;
  String? channelId;
  String? counterPartyNodeId;
  int? amount;
  String address = "";
  String? bobNodePubKeyAndAddress;
  List<ldk.ChannelDetails> channels = [];
  static const NODE_DIR = "LDK_CACHE/DAVE'S_NODE";
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  @override
  void initState() {
    initAliceNode();
    super.initState();
  }

  Future<ldk.Config> initLdkConfig(String path, String listeningAddress) async {
    // const esploraUrl = "http://10.0.0.116:3002";
    const esploraUrl = "http://0.0.0.0:3002";
    final config = ldk.Config(
        storageDirPath: path,
        esploraServerUrl: esploraUrl,
        network: ldk.Network.Regtest,
        listeningAddress: listeningAddress,
        defaultCltvExpiryDelta: 144);
    return config;
  }

  initAliceNode() async {
    final directory = await getApplicationDocumentsDirectory();
    final alicePath = "${directory.path}/$NODE_DIR";
    final aliceConfig = await initLdkConfig(alicePath, "10.0.0.116:9000");
    ldk.Builder aliceBuilder = ldk.Builder.fromConfig(config: aliceConfig);
    aliceNode = await aliceBuilder.build();
  }

  startNode() async {
    final _ = await aliceNode.start();
    final res = await aliceNode.nodeId();
    setState(() {
      aliceNodeId = res;
      displayText = "${aliceNodeId?.keyHex}.started successfully";
    });
  }

  getNodeBalances() async {
    final alice = await aliceNode.onChainBalance();
    if (kDebugMode) {
      print("alice's_balance: ${alice.confirmed}");
    }
    setState(() {
      aliceBalance = alice.confirmed;
    });
  }

  syncAliceNode() async {
    await aliceNode.syncWallets();
    await getNodeBalances();
    await getNodeInfo();
    await getListeningAddresses();
    final address = await aliceNode.newFundingAddress();
    if (kDebugMode) {
      print(address.addressHex.toString());
    }
    setState(() {
      displayText = "${aliceNodeId!.keyHex} Sync Completed";
    });
  }

  getNodeInfo() async {
    final res = await aliceNode.listChannels();
    setState(() {
      channels = res;
    });
    if (kDebugMode) {
      print("======Channels========");
      for (var e in res) {
        print("channelId: ${e.channelId}");
        print("isChannelReady: ${e.isChannelReady}");
        print("isUsable: ${e.isUsable}");
        print("localBalanceMsat: ${e.outboundCapacityMsat}");
      }
    }
  }

  Future<String> generateNewAddresses() async {
    final alice = await aliceNode.newFundingAddress();
    if (kDebugMode) {
      print("alice's address: ${alice.addressHex}");
    }

    setState(() {
      address = alice.addressHex;
      displayText = address;
    });
    return address;
  }

  getListeningAddresses() async {
    final alice = await aliceNode.listeningAddress();
    final id = "${aliceNodeId!.keyHex}@$alice";
    setState(() {
      displayText = "alice's node pubKey & Address : $id";
    });
    if (kDebugMode) {
      print("alice's listeningAddress : $id");
    }
  }

  openChannel(String? bobNodePubKeyAndAddress, int? amount) async {
    await aliceNode.connectOpenChannel(
        channelAmountSats: 10000000,
        announceChannel: true,
        nodePubkeyAndAddress: bobNodePubKeyAndAddress!);
    if (kDebugMode) {
      print("temporary channel opened");
    }
  }

  Future<String> receivePayment() async {
    final invoice = await aliceNode.receivePayment(
        amountMsat: 90000000, description: '', expirySecs: 10000);
    setState(() {
      if (kDebugMode) {
        print(invoice.hex.toString());
      }
      displayText = "Receive payment invoice${invoice.toString()}";
    });
    return invoice.toString();
  }

  sendPayments(String invoice) async {
    final _invoice = ldk.Invoice(hex: invoice);
    final paymentHash = await aliceNode.sendPayment(invoice: _invoice);
    final res = await aliceNode.paymentInfo(paymentHash: paymentHash);
    setState(() {
      displayText = "send payment success ${res?.status}";
    });
  }

  closeChannel(ldk.U8Array32 channelId, String nodeId) async {
    await aliceNode.closeChannel(
      channelId: channelId,
      counterpartyNodeId: ldk.PublicKey(keyHex: nodeId),
    );
  }

  stop() async {
    await aliceNode.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight * 1.8),
        child: Container(
          padding: const EdgeInsets.only(right: 10, left: 10, top: 40),
          color: Colors.black,
          child: Row(children: [
            Expanded(
              flex: 8,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ldk Node',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            height: 2.5,
                            color: Colors.white)),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Response:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: SelectableText(
                            displayText,
                            maxLines: 3,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: startNode,
                    icon: const Icon(
                      CupertinoIcons.power,
                      size: 20,
                      color: Colors.white,
                    ))),
            Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: syncAliceNode,
                    icon: const Icon(
                      CupertinoIcons.refresh,
                      size: 20,
                      color: Colors.white,
                    ))),
          ]),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${aliceBalance / 100000000} BTC",
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 40,
                          color: Colors.white),
                    ),
                    SelectableText(
                      aliceNodeId == null
                          ? "Node not initialized"
                          : "@Id_:${aliceNodeId!.keyHex}",
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Channels',
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w800),
                ),
                IconButton(
                    onPressed: () {
                      popUpWidget(
                        context: context,
                        title: 'Open channel',
                        widget: SizedBox(
                          height: 300,
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
                                  decoration: const InputDecoration(
                                      labelText: 'Node Pub Key & Address'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the nodePubKeyAndAddress ';
                                    }
                                    setState(() {
                                      bobNodePubKeyAndAddress = value;
                                    });
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
                                      labelText: 'Amount'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the Amount';
                                    }
                                    setState(() {
                                      amount = int.parse(value);
                                    });
                                  },
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await openChannel(
                                            bobNodePubKeyAndAddress!, amount!);
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Submit',
                                      overflow: TextOverflow.clip,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          height: 1.5,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
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
            ),
            channels.isEmpty
                ? const Text(
                    'No Open Channels',
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  )
                : ListView.builder(
                    itemCount: channels.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ListTile(
                        leading: Icon(
                          (channels[index].isUsable &&
                                  channels[index].isChannelReady)
                              ? CupertinoIcons.checkmark_seal_fill
                              : CupertinoIcons.timer_fill,
                          color: Colors.black,
                          size: 25,
                        ),
                        title: Text(
                          channels[index]
                              .channelId
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
                        subtitle: Text('1234880000 SATS',
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black.withOpacity(.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                        trailing: PopupMenuButton(itemBuilder: (context) {
                          return [
                            const PopupMenuItem<int>(
                              value: 0,
                              child: Text("Receive"),
                            ),
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text("Send"),
                            ),
                            const PopupMenuItem<int>(
                              value: 2,
                              child: Text("Close Channel"),
                            ),
                          ];
                        }, onSelected: (value) {
                          if (value == 0) {
                            popUpWidget(
                              context: context,
                              title: 'Receive',
                              widget: SizedBox(
                                height: 300,
                                child: Form(
                                  key: _formKey2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                        decoration: const InputDecoration(
                                            labelText: 'Amount'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the Amount';
                                          }
                                          setState(() {
                                            amount = int.parse(value);
                                          });
                                        },
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                          ),
                                          onPressed: () async {
                                            if (_formKey2.currentState!
                                                .validate()) {
                                              await receivePayment();
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Submit',
                                            overflow: TextOverflow.clip,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                height: 1.5,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
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
                                height: 300,
                                child: Form(
                                  key: _formKey3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextFormField(
                                        keyboardType: TextInputType.text,
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                        decoration: const InputDecoration(
                                            labelText: 'Invoice'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the Invoice';
                                          }
                                          setState(() {
                                            invoice = value;
                                          });
                                        },
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                          ),
                                          onPressed: () async {
                                            if (_formKey3.currentState!
                                                .validate()) {
                                              await sendPayments(invoice!);
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Submit',
                                            overflow: TextOverflow.clip,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                height: 1.5,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
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
                                height: 300,
                                child: Form(
                                  key: _formKey4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            counterPartyNodeId = value;
                                          });
                                        },
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                          ),
                                          onPressed: () async {
                                            if (_formKey4.currentState!
                                                .validate()) {
                                              await closeChannel(
                                                  channels[index].channelId,
                                                  counterPartyNodeId!);
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Submit',
                                            overflow: TextOverflow.clip,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                height: 1.5,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        })))
          ],
        ),
      ),
    );
  }
}
