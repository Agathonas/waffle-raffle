# waffle-raffle
<h1 align="center">
  <br>
  <a href="https://github.com/your-username/waffle-raffle"><img src="https://i.imgur.com/your-logo-url.png" alt="Waffle Raffle" width="200"></a>
  <br>
  Waffle Raffle 🧇🎉
  <br>
</h1>

<h4 align="center">Raffle the $WAFFLE // Porsche 911, Audi RS4, Macbook Pro's sweepstakes on STARKNET chain coming soon.</h4>

<p align="center">
  <a href="#how-it-works-">How It Works</a> •
  <a href="#features-">Features</a> •
  <a href="#getting-started-">Getting Started</a> •
  <a href="#smart-contract-">Smart Contract</a> •
  <a href="#contributing-">Contributing</a> •
  <a href="#license-">License</a>
</p>

---

Welcome to the Waffle Raffle project! This is an exciting raffle system built on the STARKNET chain using Cairo programming language. With Waffle Raffle, users can participate in raffles and stand a chance to win amazing prizes like Porsche 911, Audi RS4, Macbook Pro, and more! 🏎️💻

## How it Works 🎲

1. Users can enter raffles by purchasing entries using the $WAFFLE token.
2. Each raffle has a specific item up for grabs, an entry fee, and a set duration.
3. Once the raffle duration ends, a winner is randomly selected from the pool of participants.
4. The lucky winner receives the prize, and the raffle concludes.

## Features ✨

- Secure and transparent raffle system built on the STARKNET chain
- Easy participation using the $WAFFLE token
- Exciting prizes like luxury cars, high-end electronics, and more
- Completely random and fair selection of winners
- Admin panel for creating and managing raffles

## Getting Started 🚀

To get started with Waffle Raffle, follow these steps:

1. Clone the repository:
git clone https://github.com/your-username/waffle-raffle.git


Copy code

2. Install the necessary dependencies:
cd waffle-raffle
npm install


Copy code

3. Compile the Cairo contract:
starknet-compile contracts/WaffleRaffle.cairo output/WaffleRaffle.json


Copy code

4. Deploy the contract to the STARKNET network:
starknet deploy --contract output/WaffleRaffle.json --network alpha


Copy code

5. Update the contract address in the `config.ts` file.

6. Run the frontend application:
npm run dev


Copy code

7. Open your browser and visit `http://localhost:3000` to start participating in raffles!

## Smart Contract 📜

The Waffle Raffle smart contract is written in Cairo and provides the core functionality for creating, entering, and concluding raffles. The contract ensures secure and transparent operations, with only authorized admins able to create and manage raffles.

The contract leverages the power of STARKNET's scalability and security, providing a seamless and trustworthy raffle experience for all participants.

## Contributing 🤝

We welcome contributions to enhance the Waffle Raffle project! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request. Let's make this raffle system even more amazing together!

## License 📄

This project is licensed under the [MIT License](LICENSE).

---

Get ready to test your luck and win incredible prizes with Waffle Raffle! 🍀✨ Join the excitement on the STARKNET chain and experience the thrill of participating in secure and transparent raffles. Welcome aboard! 🚀🎉
