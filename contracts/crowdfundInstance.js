/* eslint-disable */
import web3 from './web3';

const address = '0x98EEA366dDbd75e7b8164cE18082Ab69478BE9Be'; // Your deployed contract's address goes here
// Example:
// const address = '0x09r80cnasjfaks93m9v2';

const abi =[
	{
		"constant": true,
		"inputs": [],
		"name": "returnAllProjects",
		"outputs": [
			{
				"name": "",
				"type": "address[]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "title",
				"type": "string"
			},
			{
				"name": "description",
				"type": "string"
			},
			{
				"name": "durationInDays",
				"type": "uint256"
			},
			{
				"name": "amountToRaise",
				"type": "uint256"
			},
			{
				"name": "reward",
				"type": "bool"
			}
		],
		"name": "startProject",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "contractAddress",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "projectStarter",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "projectTitle",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "projectDesc",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "deadline",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "goalAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "reward",
				"type": "bool"
			}
		],
		"name": "ProjectStarted",
		"type": "event"
	}
];

const instance = new web3.eth.Contract(abi, address);

export default instance;
