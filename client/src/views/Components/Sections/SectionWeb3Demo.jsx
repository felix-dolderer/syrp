// import makeStyles from "@material-ui/core/styles/makeStyles";
import React, { Component } from "react";

import ReputationContract from "contracts/Reputation.json";
import getWeb3 from "getWeb3";

// import styles from "assets/jss/material-kit-react/views/componentsSections/web3demo.js";

// const useStyles = makeStyles(styles);

class SectionWeb3Demo extends Component {
  state = {
    classes: null,
    web3: null,
    accounts: null,
    totalSupply: null,
    contract: null,
  };

  componentDidMount = async () => {
    // this.setState({classes: useStyles})
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = ReputationContract.networks[networkId];
      const instance = new web3.eth.Contract(
        ReputationContract.abi,
        deployedNetwork && deployedNetwork.address
      );
      this.setState(
        { web3, accounts, contract: instance },
        this.runReputationExample
      );
    } catch (error) {
      alert(`Failed to load web3, account, or contract.`)
      console.error(error);
    }
  }

  runReputationExample = async () => {
    const { contract } = this.state;

    const response = await contract.methods
      .totalSupply()
      .call();

    this.setState({ totalSupply: response });
  };

  render() {
    if (!this.state.web3) return <div>Loading Web3, accounts, and contract...</div>
    return (
      <div>
        <div>
          <div>
      {/* <div className={this.classes.sections}>
        <div className={this.classes.container}>
          <div className={this.classes.title}> */}
            <h2>Web3 Demo</h2>
            <p>{this.state.totalSupply}</p>
          </div>
        </div>
      </div>
    )
  }
}

export default SectionWeb3Demo;