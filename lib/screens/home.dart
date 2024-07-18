// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

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
    final builder = ldk.Builder.mutinynet()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(seedPhrase: mnemonic))
        .setStorageDirPath(await _storagePath());
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
        displayText = "${ldkNodeId?.hex}.started successfully";
      });
    } on Exception catch (e) {
      debugPrint("Error in starting Node");
      debugPrint(e.toString());
    }
  }

  onChainBalance() async {
    await ldkNode!.syncWallets();
    final balances = await ldkNode!.listBalances();
    setState(() {
      ldkNodeBalance = balances.totalOnchainBalanceSats.toInt();
    });

    if (kDebugMode) {
      print("Wallet onchain balance: $ldkNodeBalance");
    }

    await _printLogs();
  }

  newFundingAddress() async {
    final onChainPayment = await ldkNode!.onChainPayment();
    final onChainAddress = await onChainPayment.newAddress();
    if (kDebugMode) {
      print("ldkNode's address: ${onChainAddress.s}");
    }
    setState(() {
      fundingAddress = onChainAddress.s;
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
        channelAmountSats: BigInt.from(amount),
        announceChannel: true,
        pushToCounterpartyMsat:
            BigInt.from(satsToMsats(pushToCounterpartyMsat)),
        socketAddress: ldk.SocketAddress.hostname(addr: host, port: port),
        nodeId: ldk.PublicKey(hex: nodeId));
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

/*
  Future<String> receivePayment(
    int amount, {
    bool bolt12Payment = false,
    bool requestJitChannel = false,
  }) async {
    if (bolt12Payment) {
      return _receiveBolt12Payment(amount);
    } else {
      return _receiveBolt11Payment(amount,
          requestJitChannel: requestJitChannel);
    }
  }*/

  Future<String> receiveBolt11Payment({
    int? amount,
    String? description = 'test',
    int? expirySecs = 3600,
    bool? requestJitChannel = false,
  }) async {
    ldk.Bolt11Invoice invoice;
    if (requestJitChannel == true) {
      invoice = await _receiveViaJitChannel(
        amount: amount,
        description: description!,
        expirySecs: expirySecs!,
      );
    } else {
      final bolt11Payment = await ldkNode!.bolt11Payment();
      invoice = amount == null
          ? await bolt11Payment.receiveVariableAmount(
              description: description!,
              expirySecs: expirySecs!,
            )
          : await bolt11Payment.receive(
              amountMsat: BigInt.from(satsToMsats(amount)),
              description: description!,
              expirySecs: expirySecs!,
            );
    }
    setState(() {
      if (kDebugMode) {
        print(invoice.signedRawInvoice.toString());
      }
      displayText =
          "Receive payment invoice${invoice.signedRawInvoice.toString()}";
    });
    return invoice.signedRawInvoice.toString();
  }

  Future<ldk.Bolt11Invoice> _receiveViaJitChannel({
    int? amount,
    required String description,
    required int expirySecs,
  }) async {
    final bolt11Payment = await ldkNode!.bolt11Payment();
    return amount == null
        ? await bolt11Payment.receiveVariableAmountViaJitChannel(
            description: description, expirySecs: expirySecs)
        : await bolt11Payment.receiveViaJitChannel(
            amountMsat: BigInt.from(satsToMsats(amount)),
            description: description,
            expirySecs: expirySecs);
  }

  Future<String> receiveBolt12Payment({
    int? amount,
    String? description = 'test',
  }) async {
    final bolt12Payment = await ldkNode!.bolt12Payment();
    final offer = amount == null
        ? await bolt12Payment.receiveVariableAmount(
            description: description!,
          )
        : await bolt12Payment.receive(
            amountMsat: BigInt.from(satsToMsats(amount)),
            description: description!,
          );
    setState(() {
      if (kDebugMode) {
        print(offer.s);
      }
      displayText = "Receive payment offer${offer.s}";
    });
    return offer.s;
  }

  Future<String> sendPayment(String invoice) async {
    final bolt11Payment = await ldkNode!.bolt11Payment();
    final paymentId = await bolt11Payment.send(
      invoice: ldk.Bolt11Invoice(
        signedRawInvoice: invoice,
      ),
    );

    final res = await ldkNode!.payment(paymentId: paymentId);
    setState(() {
      displayText = "send payment success ${res?.status}";
    });
    return "${res?.status}";
  }

  Future<void> closeChannel(
      ldk.UserChannelId channelId, ldk.PublicKey nodeId) async {
    await ldkNode!.closeChannel(
      userChannelId: channelId,
      counterpartyNodeId: nodeId,
    );

    await listChannels();
  }

  stop() async {
    await ldkNode!.stop();
  }

  Future<String> _storagePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final storagePath = "${directory.path}/$LDK_NODE_DIR";
    debugPrint('Storage Path: $storagePath');
    return storagePath;
  }

  Future<void> _printLogs() async {
    final logsFile = File('${await _storagePath()}/logs/ldk_node_latest.log');
    String contents = await logsFile.readAsString();

    // Define the maximum length of each chunk to be printed
    const int chunkSize = 1024;

    // Split the contents into chunks and print each chunk
    for (int i = 0; i < contents.length; i += chunkSize) {
      int end =
          (i + chunkSize < contents.length) ? i + chunkSize : contents.length;
      print(contents.substring(i, end));
    }
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
                        nodeId: ldkNodeId!.hex,
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
                      /* Receive via JIT Channel */
                      SubmitButton(
                        text: 'Receive via Lightning',
                        callback: () => popUpWidget(
                          context: context,
                          title: 'Receive via Lightning',
                          widget: ReceivePopupWidget(
                            receivePaymentCallBack: ({int? amount}) =>
                                receiveBolt11Payment(
                              amount: amount,
                              requestJitChannel: true,
                            ),
                          ),
                        ),
                      ),
                      /* New Bolt12 Offer */
                      SubmitButton(
                        text: 'New Bolt12 Offer',
                        callback: () => popUpWidget(
                          context: context,
                          title: 'Receive via Bolt12 Offer',
                          widget: ReceivePopupWidget(
                            receivePaymentCallBack: receiveBolt12Payment,
                          ),
                        ),
                      ),
                      SubmitButton(
                        text: 'List Channels',
                        callback: listChannels,
                      ),
                      /* ChannelsActionBar */
                      ChannelsActionBar(
                        openChannelCallBack: connectOpenChannel,
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
                          : ChannelListWidget(
                              channels: channels,
                              closeChannelCallBack: closeChannel,
                              receivePaymentCallBack: receiveBolt11Payment,
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
