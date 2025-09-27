// Blockchain service utilities
import { ethers } from 'ethers';

export class Web3Service {
  constructor() {
    this.provider = null;
    this.signer = null;
    this.contract = null;
  }

  async connect() {
    try {
      if (typeof window.ethereum !== 'undefined') {
        this.provider = new ethers.BrowserProvider(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        this.signer = await this.provider.getSigner();
        return true;
      } else {
        console.warn('MetaMask not detected. Using mock data.');
        return false;
      }
    } catch (error) {
      console.error('Error connecting to Web3:', error);
      return false;
    }
  }

  async getAccount() {
    if (this.signer) {
      return await this.signer.getAddress();
    }
    return null;
  }

  async getBalance() {
    if (this.signer) {
      const address = await this.signer.getAddress();
      const balance = await this.provider.getBalance(address);
      return ethers.formatEther(balance);
    }
    return '0';
  }

  // Mock contract interactions for demo
  async callContract(method, params = []) {
    // In a real app, this would interact with your smart contract
    console.log(`Mock contract call: ${method}`, params);
    return { success: true, data: 'mock_response' };
  }
}

export const formatAddress = (address) => {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

export const formatHash = (hash) => {
  if (!hash) return '';
  return `${hash.slice(0, 10)}...${hash.slice(-8)}`;
};

export const validateAddress = (address) => {
  try {
    ethers.getAddress(address);
    return true;
  } catch {
    return false;
  }
};