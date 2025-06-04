# LDK Node Flutter Demo

LDK Node Flutter Demo is a **non-custodial Lightning Network node** running in a Flutter app. It uses the [Lightning Dev Kit (LDK)](https://lightningdevkit.org/) and [Bitcoin Dev Kit (BDK)](https://bitcoindevkit.org/) libraries to provide a simple, integrated Lightning + Bitcoin wallet on mobile. The app initializes a node from a BIP39 mnemonic seed and starts the Lightning node with an on-chain Bitcoin wallet. Once running, the UI displays the node’s public key (ID) and allows managing on-chain balances and Lightning channels. *(Note: this demo is experimental and intended for development/test use only.)*

## Features

- **Lightning Node & Wallet**: A full Lightning node with an integrated Bitcoin on-chain wallet. Users can start the node from a mnemonic seed, view the node’s ID, check on-chain balances, and generate Bitcoin addresses for funding.
- **Channel Management**: Connect to peers and open Lightning payment channels. Channels are the basic building blocks of Lightning payments. The app lets you list existing channels (showing capacity and status) and close them as needed.
- **Lightning Payments**: Send and receive Lightning payments. You can create BOLT11 invoices or BOLT12 “offers” to receive payments. The demo also supports **Just-In-Time (JIT) channels**, where a channel is automatically opened to receive a payment if none exists.
- **Cross-Platform UI**: The Flutter interface (Android/iOS) provides real-time status updates. Buttons and forms allow checking balances, generating invoices, opening channels, sending payments, etc., all within the app.

## Prerequisites

To run the LDK Node demo, you need the following:

- [Flutter SDK](https://flutter.dev/) (for building and running the app).
- [ldk_node Flutter package](https://pub.dev/packages/ldk_node) (v0.3.0) added to `pubspec.yaml`.
- [path_provider](https://pub.dev/packages/path_provider) plugin (for on-device storage).
- **BIP-39 mnemonic** (12/24-word seed) for initializing the node’s wallet.
- **Internet connection** and access to blockchain data (e.g. a public Esplora/Electrum API).
- Android Studio / Xcode (or similar) to run on an Android or iOS device/emulator.

## Installation

1. **Clone the repository** (replace with the actual repo URL):
    ```sh
    git clone https://github.com/YourUser/ldk-node-flutter-demo.git
    cd ldk-node-flutter-demo
    ```
2. **Install Flutter dependencies**:
    ```sh
    flutter pub get
    ```
3. **Run the app** on a connected device or emulator:
    ```sh
    flutter run
    ```

## Usage

1. **Launch the app**. On first run, you will see a prompt for a mnemonic phrase. Enter an existing BIP39 seed or create a new one. This initializes and starts the Lightning node.
2. Once the node starts, the UI will display your node’s public key (ID) and a balance widget. Tap **On Chain Balance** to synchronize the wallet and view any on-chain BTC funds.
3. Tap **New Funding Address** to generate a Bitcoin address. Use a Bitcoin wallet or faucet (e.g. testnet coins) to send funds to this address. After funding, tap **On Chain Balance** again to update the balance.
4. To receive a Lightning payment, tap **Receive via Lightning** (for a BOLT11 invoice) or **New Bolt12 Offer** (for a BOLT12 offer). The app will display an invoice string (or offer) you can share with a payer. When the payer sends to this invoice, you’ll receive the payment (automatically opening a channel via JIT if needed).
5. Tap **List Channels** to view open channels. To open a new channel, fill in the peer’s host, port, node ID, the channel amount (satoshis), and optional push amount, then submit. This connects to the peer and funds a channel.
6. In the channel list, each channel entry shows actions such as **Send Payment** and **Close Channel**. Use **Send Payment** to pay a Lightning invoice through that channel, or **Close Channel** to close it cooperatively. Closed channels are removed from the list.
7. (Optional) When finished, you can stop the node by closing the app or terminating it from your development environment.

## License

This project is licensed under the **MIT License**. See the [LICENSE](https://opensource.org/licenses/MIT) file for details.

## Acknowledgements

- The **Lightning Dev Kit (LDK)** and **Bitcoin Dev Kit (BDK)** projects, for the underlying Lightning and Bitcoin libraries.
- The [ldk_node Flutter package](https://pub.dev/packages/ldk_node) (ltbl.io) which bridges LDK/BDK into Dart/Flutter.
- The **Flutter** framework for building the cross-platform UI.

---

We hope you find this demo useful! If you have any questions or need assistance, feel free to open an issue in the repository. Happy Lightning!
