import { BigNumber, Signer } from 'ethers';
import { ethers } from 'hardhat';
import chai from 'chai';
import {
  MockContractFactory,
  MockContract,
  smock,
} from '@defi-wonderland/smock';
import { Token, Token__factory } from '../typechain';

const { expect } = chai;
chai.use(smock.matchers);

let tokenFactory: MockContractFactory<Token__factory>;
let signers: Signer[];

describe('Token', () => {
  let token: MockContract<Token>;
  beforeEach(async () => {
    tokenFactory = await smock.mock<Token__factory>('Token');
    token = await tokenFactory.deploy();
  });
  describe('Transfer', () => {
    let deployer: Signer, acc1: Signer, acc2: Signer;
    beforeEach(async () => {
      [deployer, acc1, acc2] = await ethers.getSigners();
      //Set balance of acc1 to 1000
      await token.setVariable('balances', {
        [await acc1.getAddress()]: 1000,
      });
    });
    it('Not enough balance', async () => {
      expect(await token.balanceOf(await acc1.getAddress())).to.equal(
        BigNumber.from(1000)
      );
      expect(await token.balanceOf(await acc2.getAddress())).to.equal(
        BigNumber.from(0)
      );
      expect(token.connect(acc2).transfer(acc1, 100)).to.be.revertedWith(
        'Not enough tokens'
      );
      expect(token.connect(acc1).transfer(acc2, 100)).to.be.revertedWith(
        'Not enough tokens'
      );
    });
    it('Success Transfer', async () => {
      let acc1Address = await acc1.getAddress();
      let acc2Address = await acc2.getAddress();
      let amount = 100;
      let tx = await token.connect(acc1).transfer(acc2Address, amount);

      expect(tx)
        .to.emit(token, 'Transfer')
        .withArgs(acc1Address, acc2Address, amount);

      let acc1Balance: BigNumber = await token.balanceOf(acc1Address);
      let acc2Balance: BigNumber = await token.balanceOf(
        await acc2.getAddress()
      );
      expect(acc1Balance).to.equal(BigNumber.from(900));
      expect(acc2Balance).to.equal(BigNumber.from(amount));
    });
  });
});
