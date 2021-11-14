# SYRP
## Synergetic Reputation Engine

This is the source code for the project presented at the Blockckain Hackathon 2021 under the name "SyRP, the synergetic reputation engine".
The objective of our token is to make trust between local parties tangible and usable in different areas of life. Positive behaviour (e.g. the repayment of a loan) is rewarded with an increase of trust between two accounts.

With this reward, local networks are incentivized to collaborate with each other and trustful parties receive a greater trust score, making them the preferred participant in a credit flow.

While the underlying intention of making trust and reputation tangible is applicable to many systems, such as digital identity and social networks, this code focuses on its implementation in a credit system.

### Running locally
The contracts can be run via truffle in your local network.

For this, install truffle (best globally) and start the development console (`truffle develop`).
Install openzeppelin/contracts  - `npm i @openzeppelin/contracts` & for the tests `npm i truffle-assertions`
Now you are free to play with the contract locally. 
With truffle running on your local network, go to the client directory and start the React app with `npm run start` to interact with the contract through our GUI. 

#### Tests
In the truffle console, run `test`.
Feel free to dive into the tests scenarios to get an understanding of the desired behaviour.
