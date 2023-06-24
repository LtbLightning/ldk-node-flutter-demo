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
  int aliceBalance = 0;
  String displayText = "";
  String address = "";
  List<ldk.ChannelDetails> channels = [];
  static const NODE_DIR = "LDK_CACHE/DAVE'S_NODE";

  @override
  void initState() {
    initAliceNode();
    super.initState();
  }

  initAliceNode() async {
    final directory = await getApplicationDocumentsDirectory();
    final alicePath = "${directory.path}/$NODE_DIR";
    // const esploraUrl = "http://10.0.0.116:3002";
    const esploraUrl = "http://0.0.0.0:3002";
    final config = ldk.Config(
        storageDirPath: alicePath,
        network: ldk.Network.regtest,
        listeningAddress:
            const ldk.NetAddress.iPv4(addr: '0.0.0.0', port: 5004),
        onchainWalletSyncIntervalSecs: 30,
        walletSyncIntervalSecs: 30,
        feeRateCacheUpdateIntervalSecs: 100,
        logLevel: ldk.LogLevel.info,
        defaultCltvExpiryDelta: 144);
    aliceNode = await ldk.Builder.fromConfig(config: config)
        .setEntropyBip39Mnemonic(
            mnemonic: const ldk.Mnemonic(
                internal:
                    'usual borrow equal obtain lazy grace jungle hungry shuffle type gasp install'))
        .setEsploraServer(esploraServerUrl: esploraUrl)
        .build();
  }

  startNode() async {
    final _ = await aliceNode!.start();
    final res = await aliceNode!.nodeId();

    setState(() {
      aliceNodeId = res;
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
    print("syncing");
    await aliceNode!.syncWallets();
    print("syncing complete");
    await getNodeBalance();
    await getChannels();
    setState(() {
      displayText = "${aliceNodeId!.internal} Sync Completed";
    });
  }

  getListeningAddress() async {
    final alice = await aliceNode!.listeningAddress();
    final id = "${aliceNodeId!.internal}@${alice?.addr}:${alice!.port}";
    setState(() {
      displayText = "alice's node pubKey & Address : $id";
    });
    if (kDebugMode) {
      print("alice's listeningAddress : $id");
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

  nextEvent() async {
    final res = await aliceNode!.nextEvent();
    if (kDebugMode) {
      print(res.toString());
    }
    await aliceNode!.eventHandled();
  }

  getNewAddress() async {
    final address = await aliceNode!.newFundingAddress();
    if (kDebugMode) {
      print(address.internal.toString());
    }
    setState(() {
      displayText = address.internal;
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
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
              // SubmitButton(
              //   text: 'Next Event',
              //   callback: nextEvent,
              // ),
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
