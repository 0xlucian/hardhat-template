import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { ethers } from 'hardhat';
import chai from 'chai';
import {
  MockContractFactory,
  MockContract,
  FakeContract,
  smock,
} from '@defi-wonderland/smock';
import { Token, Token__factory } from '../typechain-types';
import { sign } from 'crypto';

const { expect } = chai;
chai.use(smock.matchers);

let tokenFactory: MockContractFactory<Token__factory>;
let signers: SignerWithAddress[];

describe('Token', () => {
  let token: MockContract<Token>;
  beforeEach(async () => {
    tokenFactory = await smock.mock<Token__factory>('Token');
    token = await tokenFactory.deploy();
  });
  describe('Transfer', () => {
    beforeEach(async () => {});
    it('Not enough balance', async () => {
      expect(true);
    });
  });
});
