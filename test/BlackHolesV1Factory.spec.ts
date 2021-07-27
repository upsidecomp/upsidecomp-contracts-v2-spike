import { ethers, waffle } from 'hardhat';
import { BlackHoles } from '../typechain/BlackHoles';
import { expect } from './shared/expect';
import snapshotGasCost from './shared/snapshotGasCost';

import { FeeAmount, getCreate2Address } from './shared/utilities';

const { constants } = ethers;

const createFixtureLoader = waffle.createFixtureLoader;

const POOL_OWNER = '0x1000000000000000000000000000000000000000';

describe('BlackHolesV1Factory', () => {
  const [wallet, other] = waffle.provider.getWallets();

  let blackholes: BlackHoles;
  let poolBytecode: string;

  const fixture = async () => {
    const bh = await ethers.getContractFactory('BlackHoles');
    return (await bh.deploy()) as BlackHoles;
  };

  let loadFixture: ReturnType<typeof createFixtureLoader>;
  before('create fixture loader', async () => {
    loadFixture = createFixtureLoader([wallet, other]);
  });

  before('load pool bytecode', async () => {
    poolBytecode = (await ethers.getContractFactory('BlackHoles')).bytecode;
  });

  beforeEach('deploy factory', async () => {
    blackholes = await loadFixture(fixture);
  });

  it('owner is deployer', async () => {
    // expect(await blackholes.owner()).to.eq(wallet.address);
  });

  it('factory bytecode size', async () => {
    expect(((await waffle.provider.getCode(blackholes.address)).length - 2) / 2).to.matchSnapshot();
  });
});
