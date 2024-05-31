// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:ldk_node_flutter_demo/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ldk.Node? ldkNode;
  ldk.PublicKey? ldkNodeId;
  bool built = false;
  bool started = false;
  static const LDK_NODE_DIR = "LDK_NODE";
  String displayText = "";
  String fundingAddress = "";
  String listeningAddress = "";
  int ldkNodeBalance = 0;
  List<ldk.ChannelDetails> channels = [];

  @override
  void initState() {
    super.initState();
  }

  buildNode(String mnemonic) async {
    final directory = await getApplicationDocumentsDirectory();
    final storagePath = "${directory.path}/$LDK_NODE_DIR";
    debugPrint('Storage Path: $storagePath');
    const localEsploraUrl = "https://testnet-electrs.ltbl.io:3004";
    final builder = ldk.Builder()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(mnemonic))
        .setListeningAddresses(
            [const ldk.SocketAddress.hostname(addr: "0.0.0.0", port: 3005)])
        .setNetwork(ldk.Network.Testnet)
        .setStorageDirPath(storagePath)
        .setEsploraServer(localEsploraUrl);
    ldkNode = await builder.build();
    await start();
    await getListeningAddress();
  }

  start() async {
    try {
      final _ = await ldkNode!.start();
      ldkNodeId = await ldkNode!.nodeId();
      setState(() {
        started = true;
        displayText = "${ldkNodeId?.hexCode}.started successfully";
      });
    } on Exception catch (e) {
      debugPrint("Error in starting Node");
      debugPrint(e.toString());
    }
  }

  onChainBalance() async {
    await ldkNode!.syncWallets();
    final balance = await ldkNode!.totalOnchainBalanceSats();
    setState(() {
      ldkNodeBalance = balance;
    });

    if (kDebugMode) {
      print("Wallet onchain balance: $ldkNodeBalance");
    }
  }

  newFundingAddress() async {
    final ldkNodeAddress = await ldkNode!.newOnchainAddress();
    if (kDebugMode) {
      print("ldkNode's address: ${ldkNodeAddress.s}");
    }
    setState(() {
      fundingAddress = ldkNodeAddress.s;
    });
  }

  getListeningAddress() async {
    final hostAndPort = await ldkNode!.listeningAddresses();
    final addr = hostAndPort![0];

    setState(() {
      addr.maybeMap(
          orElse: () {},
          hostname: (e) {
            listeningAddress = "${e.addr}:${e.port}";
          });
    });
  }

  Future<void> connectOpenChannel(String host, int port, String nodeId,
      int amount, int pushToCounterpartyMsat) async {
    await ldkNode!.connectOpenChannel(
        channelAmountSats: amount,
        announceChannel: true,
        pushToCounterpartyMsat: satsToMsats(pushToCounterpartyMsat),
        netaddress: ldk.SocketAddress.hostname(addr: host, port: port),
        nodeId: ldk.PublicKey(hexCode: nodeId));
    if (kDebugMode) {
      print("temporary channel opened");
    }
  }

  listChannels() async {
    final res = await ldkNode!.listChannels();
    setState(() {
      channels = res;
    });
    if (kDebugMode) {
      print("======Channels========");
      for (var e in res) {
        inspect(e);
        print("isChannelReady: ${e.isChannelReady}");
        print("isUsable: ${e.isUsable}");
        print("confirmation: ${e.confirmations}");
        print("localBalanceMsat: ${e.outboundCapacityMsat}");
      }
    }
  }

  Future<String> receivePayment(int amount) async {
    final invoice = await ldkNode!.receivePayment(
      amountMsat: satsToMsats(amount),
      description: 'test',
      expirySecs: 9000,
    );
    setState(() {
      if (kDebugMode) {
        print(invoice.signedRawInvoice.toString());
      }
      displayText =
          "Receive payment invoice${invoice.signedRawInvoice.toString()}";
    });
    return invoice.signedRawInvoice.toString();
  }

  Future<String> sendPayment(String invoice) async {
    final paymentHash = await ldkNode!
        .sendPayment(invoice: ldk.Bolt11Invoice(signedRawInvoice: invoice));
    final res = await ldkNode!.payment(paymentHash: paymentHash);
    setState(() {
      displayText = "send payment success ${res?.status}";
    });
    return "${res?.status}";
  }

  Future<void> closeChannel(
      ldk.ChannelId channelId, ldk.PublicKey nodeId) async {
    await ldkNode!.closeChannel(
      channelId: channelId,
      counterpartyNodeId: nodeId,
    );

    await listChannels();
  }

  stop() async {
    await ldkNode!.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: !started
                ? MnemonicWidget(
                    buildCallBack: (String e) async {
                      await buildNode(e);
                    },
                  )
                : Column(
                    children: [
                      /* Balance */
                      BalanceWidget(
                        balance: ldkNodeBalance,
                        nodeId: ldkNodeId!.hexCode,
                        fundingAddress: fundingAddress,
                        listeningAddress: listeningAddress,
                      ),
                      const SizedBox(height: 5),
                      SubmitButton(
                        text: 'On Chain Balance',
                        callback: onChainBalance,
                      ),
                      /* New Funding Address */
                      SubmitButton(
                        text: 'New Funding Address',
                        callback: newFundingAddress,
                      ),
                      SubmitButton(
                        text: 'List Channels',
                        callback: listChannels,
                      ),
                      /* ChannelsActionBar */
                      ChannelsActionBar(
                          openChannelCallBack: connectOpenChannel),
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
                          : ChannelListWidget(
                              channels: channels,
                              closeChannelCallBack: closeChannel,
                              receivePaymentCallBack: receivePayment,
                              sendPaymentCallBack: sendPayment,
                            )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
