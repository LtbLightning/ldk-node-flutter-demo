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
  bool isInitialized = false;
  static const NODE_DIR = "LDK_CACHE/ALICE'S_NODE";
  String displayText = "";
  int aliceBalance = 0;
  List<ldk.ChannelDetails> channels = [];

  @override
  void initState() {
    super.initState();
  }

  initAliceNode(String mnemonic) async {
    final directory = await getApplicationDocumentsDirectory();
    final alicePath = "${directory.path}/$NODE_DIR";
    const esploraUrl = "http://0.0.0.0:3002";
    final builder = ldk.Builder()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(internal: mnemonic))
        .setStorageDirPath(alicePath)
        .setListeningAddress(
            const ldk.NetAddress.iPv4(addr: '0.0.0.0', port: 5005))
        .setNetwork(ldk.Network.regtest)
        .setEsploraServer(esploraServerUrl: esploraUrl);
    aliceNode = await builder.build();
    setState(() {
      isInitialized = true;
    });
  }

  startNode() async {
    final _ = await aliceNode!.start();
    aliceNodeId = await aliceNode!.nodeId();
    setState(() {
      displayText = "${aliceNodeId?.internal}.started successfully";
    });
  }

  getNodeBalance() async {
    final alice = await aliceNode!.onChainBalance();

    if (kDebugMode) {
      print("alice's_balance: ${alice.confirmed}");
    }
    setState(() {
      aliceBalance = alice.confirmed;
    });
  }

  syncAliceNode() async {
    await aliceNode!.syncWallets();
    final alice = await aliceNode!.onChainBalance();
    await getChannels();
    setState(() {
      aliceBalance = alice.confirmed;
    });
    if (kDebugMode) {
      print("alice's_balance: $aliceBalance");
    }
    setState(() {
      displayText = "${aliceNodeId!.internal} Sync Completed";
    });
  }

  getNewAddress() async {
    final aliceAddress = await aliceNode!.newFundingAddress();
    if (kDebugMode) {
      print("Alice's address: ${aliceAddress.internal}");
    }
    setState(() {
      displayText = aliceAddress.internal;
    });
  }

  getListeningAddress() async {
    final alice = await aliceNode!.listeningAddress();
    setState(() {
      displayText =
          "alice's node \n host addr: ${alice!.addr} \n port: ${alice.port} ";
    });
  }

  Future<void> openChannel(
      String host, int port, String nodeId, int amount) async {
    await aliceNode!.connectOpenChannel(
        channelAmountSats: amount,
        announceChannel: true,
        address: ldk.NetAddress.iPv4(addr: host, port: port),
        nodeId: ldk.PublicKey(internal: nodeId));
    if (kDebugMode) {
      print("temporary channel opened");
    }
  }

  getChannels() async {
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
      appBar: buildAppBar(context, startNode, syncAliceNode),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: !isInitialized
              ? MnemonicWidget(
                  buildCallBack: (String e) async {
                    await initAliceNode(e);
                  },
                )
              : Column(
                  children: [
                    ResponseContainer(
                      text: displayText ?? '',
                    ),
                    // /* Balance */
                    BalanceWidget(
                      balance: aliceBalance,
                      nodeId: aliceNodeId == null
                          ? 'Not Initialized'
                          : aliceNodeId!.internal,
                    ),
                    const SizedBox(height: 20),
                    // /* GetAddressButton */
                    SubmitButton(
                      text: 'Get New Address',
                      callback: getNewAddress,
                    ),
                    /* Get Listening Address Button */
                    SubmitButton(
                      text: 'Get Listening Address',
                      callback: getListeningAddress,
                    ),

                    /* ChannelsActionBar */
                    ChannelsActionBar(openChannelCallBack: openChannel),
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
