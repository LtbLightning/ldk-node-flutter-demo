import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:ldk_node_flutter_quickstart/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ldk.Node? aliceNode;
  ldk.PublicKey? aliceNodeId;
  bool built = false;
  bool started = false;
  static const NODE_DIR = "LDK_CACHE/ALICE'S_NODE";
  String displayText = "";
  int aliceBalance = 0;
  List<ldk.ChannelDetails> channels = [];

  @override
  void initState() {
    super.initState();
  }

  buildNode(String mnemonic) async {
    final directory = await getApplicationDocumentsDirectory();
    final alicePath = "${directory.path}/$NODE_DIR";
    const esploraUrl = "https://blockstream.info/testnet/api";
    final builder = ldk.Builder()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(internal: mnemonic))
        .setListeningAddress(
            const ldk.NetAddress.iPv4(addr: '0.0.0.0', port: 5005))
        .setNetwork(ldk.Network.testnet)
        .setStorageDirPath(alicePath)
        .setEsploraServer(esploraServerUrl: esploraUrl);
    aliceNode = await builder.build();
    setState(() {
      built = true;
    });
  }

  start() async {
    final _ = await aliceNode!.start();
    aliceNodeId = await aliceNode!.nodeId();
    setState(() {
      started = true;
      displayText = "${aliceNodeId?.internal}.started successfully";
    });
  }

  onChainBalance() async {
    final alice = await aliceNode!.totalOnchainBalanceSats();
    if (kDebugMode) {
      print("alice's_balance: ${alice}");
    }
    setState(() {
      aliceBalance = alice;
    });
  }

  newFundingAddress() async {
    final aliceAddress = await aliceNode!.newOnchainAddress();
    if (kDebugMode) {
      print("Alice's address: ${aliceAddress.internal}");
    }
    setState(() {
      displayText = aliceAddress.internal;
    });
  }

  listeningAddress() async {
    final alice = await aliceNode!.listeningAddress();
    setState(() {
      displayText =
          "alice's node \n host addr: ${alice!.addr} \n port: ${alice.port} ";
    });
  }

  Future<void> connectOpenChannel(String host, int port, String nodeId,
      int amount, int pushToCounterpartyMsat) async {
    await aliceNode!.connectOpenChannel(
        channelAmountSats: amount,
        announceChannel: true,
        pushToCounterpartyMsat: pushToCounterpartyMsat,
        address: ldk.NetAddress.iPv4(addr: host, port: port),
        nodeId: ldk.PublicKey(internal: nodeId));
    if (kDebugMode) {
      print("temporary channel opened");
    }
  }

  listChannels() async {
    final res = await aliceNode!.listChannels();
    setState(() {
      channels = res;
    });
    if (kDebugMode) {
      print("======Channels========");
      for (var e in res) {
        print("isChannelReady: ${e.isChannelReady}");
        print("isUsable: ${e.isUsable}");
        print("confirmation: ${e.confirmations}");
        print("localBalanceMsat: ${e.outboundCapacityMsat}");
      }
    }
  }

  Future<String> receivePayment(int amount) async {
    final invoice = await aliceNode!
        .receivePayment(amountMsat: amount, description: '', expirySecs: 10000);
    setState(() {
      if (kDebugMode) {
        print(invoice.internal.toString());
      }
      displayText = "Receive payment invoice${invoice.internal.toString()}";
    });
    return invoice.toString();
  }

  Future<void> sendPayment(String invoice) async {
    final paymentHash =
        await aliceNode!.sendPayment(invoice: ldk.Invoice(internal: invoice));
    final res = await aliceNode!.payment(paymentHash: paymentHash);
    setState(() {
      displayText = "send payment success ${res?.status}";
    });
  }

  Future<void> closeChannel(ldk.ChannelId channelId, String nodeId) async {
    await aliceNode!.closeChannel(
      channelId: channelId,
      counterpartyNodeId: ldk.PublicKey(internal: nodeId),
    );
  }

  stop() async {
    await aliceNode!.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: !built
              ? MnemonicWidget(
                  buildCallBack: (String e) async {
                    await buildNode(e);
                  },
                )
              : Column(
                  children: [
                    ResponseContainer(
                      text: displayText ?? '',
                    ),

                    /* Start */
                    !started
                        ? SubmitButton(
                            text: 'Start',
                            callback: start,
                          )
                        : const SizedBox(),
                    /* Balance */
                    BalanceWidget(
                      balance: aliceBalance,
                      nodeId: aliceNodeId == null
                          ? 'Not Initialized'
                          : aliceNodeId!.internal,
                    ),
                    const SizedBox(height: 20),
                    SubmitButton(
                      text: 'On Chain Balance',
                      callback: onChainBalance,
                    ),
                    /* New Funding Address */
                    SubmitButton(
                      text: 'New Funding Address',
                      callback: newFundingAddress,
                    ),
                    /* Listening Address */
                    SubmitButton(
                      text: 'Listening Address',
                      callback: listeningAddress,
                    ),
                    SubmitButton(
                      text: 'List Channels',
                      callback: listChannels,
                    ),
                    /* ChannelsActionBar */
                    ChannelsActionBar(openChannelCallBack: connectOpenChannel),
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
    );
  }
}
