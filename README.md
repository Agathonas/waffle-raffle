# Waffle Raffle 🧇

<h1 align="center">
  <br>
  <a href="https://twitter.com/wafflesweep"><img src="https://i.imgur.com/sFmAOBq.png" alt="Waffle Raffle" width="200"></a>
  <br>
  Waffle Raffle
  <br>
</h1>

<h4 align="center">Raffle the $WAFFLE token and win exciting prizes while supporting charitable causes on the Starknet chain.</h4>

<p align="center">
  <a href="https://twitter.com/wafflesweep">Twitter</a> •
  <a href="#how-it-works-">How It Works</a> •
  <a href="#features-">Features</a> •
  <a href="#smart-contract-">Smart Contract</a> •
  <a href="#airdrop-">Airdrop</a> •
  <a href="#token-announcement-">Token Announcement</a> •
  <a href="#contributing-">Contributing</a> •
  <a href="#license-">License</a>
</p>

---

## How it Works 🎲

1. Users can enter raffles by purchasing entries using the $WAFFLE token.
2. Each raffle has a specific item up for grabs, an entry fee, and a set duration.
3. A portion of the total amount collected in each raffle (0-30%) is allocated as a fee to support charitable causes and fund development.
4. Once the raffle duration ends, a winner is randomly selected from the pool of participants.
5. The lucky winner receives the prize, and the raffle concludes.

## Features ✨

- Secure and transparent raffle system built on the Starknet chain
- Easy participation using the $WAFFLE token
- Exciting prizes like luxury cars, high-end electronics, and more
- Completely random and fair selection of winners
- Admin panel for creating and managing raffles
- Customizable fee percentage (0-30%) for each raffle to support charitable causes and fund development
- Refund mechanism if the target amount is not reached
- Organization account for managing fees and charitable contributions
- Merkle proof-based airdrop system for efficient token distribution
- Comment extraction from X.com contest posts for airdrop eligibility

## Smart Contract 📜

The Waffle Raffle smart contract is written in Cairo and provides the core functionality for creating, entering, and concluding raffles. The contract ensures secure and transparent operations, with only authorized admins able to create and manage raffles.

The contract leverages the power of Starknet's scalability and security, providing a seamless and trustworthy raffle experience for all participants.

### Contract Features

- `create_raffle`: Allows admins to create a new raffle by specifying the item, target amount, duration, and fee percentage.
- `enter_raffle`: Enables users to enter a raffle by purchasing entries with $WAFFLE tokens.
- `end_raffle`: Concludes a raffle and selects a winner if the target amount is reached. If the target amount is not reached, participants are refunded.
- `transfer_fees`: Transfers the fee amount collected in a raffle to the organization account.
- `withdraw_funds`: Allows the admin to withdraw funds from the organization account.
- `set_airdrop_merkle_root`: Sets the Merkle root for the airdrop distribution.
- `claim_airdrop`: Allows users to claim their airdrop tokens using Merkle proofs.

## Airdrop 🎉

To celebrate the launch of the $WAFFLE token, we are conducting an airdrop for the community. Users can participate in the airdrop by following these steps:

1. Follow our official Twitter account [@wafflesweep](https://twitter.com/wafflesweep).
2. Retweet and like the pinned airdrop announcement tweet.
3. Comment on the airdrop announcement tweet with your Starknet address.
4. Engage with our X.com contest posts by leaving comments.

The airdrop distribution will be based on a Merkle tree, ensuring efficient and secure token allocation. Users can claim their airdrop tokens by providing their Starknet address and the corresponding Merkle proof.

We will extract comments from our X.com contest posts to determine airdrop eligibility and allocate tokens accordingly.

## Token Announcement 📣

We are excited to announce the $WAFFLE token, the native utility token of the Waffle Raffle ecosystem. The $WAFFLE token will be used for purchasing raffle entries, paying fees, and participating in governance decisions.

The total supply of $WAFFLE tokens is 1 billion, with the following allocation:
- 60% for airdrop to the community
- 20% for liquidity pool
- 20% for team allocation

The $WAFFLE token will be launched on the Starknet chain, providing fast and secure transactions within the Waffle Raffle ecosystem.

## Contributing 🤝

We welcome contributions to enhance the Waffle Raffle project! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request. Let's make this raffle system even more amazing together and support charitable causes along the way!

## License 📄

This project is licensed under the [MIT License](LICENSE).

---

Join the Waffle Raffle today and experience the excitement of participating in secure and transparent raffles while making a positive impact on the world! 🌍✨ Together, we can create a fun and rewarding way to support charitable causes and fund development. Let's make a difference! 🙌🎉
