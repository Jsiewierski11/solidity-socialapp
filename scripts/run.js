// This is a simple test script to simulate the wave functionality locally.
const main = async () => {
    const waveContractFactory = await hre.ethers.getContractFactory('WavePortal');
    const waveContract = await waveContractFactory.deploy({
        value: hre.ethers.utils.parseEther('0.1'),
    });
    await waveContract.deployed();
    console.log("Contract deployed to: ", waveContract.address);

    let contractBlance = await hre.ethers.provider.getBalance(waveContract.address);
    console.log(
        'Contract balance: ',
        hre.ethers.utils.formatEther(contractBlance)
    );

    const waveTxn = await waveContract.wave('This is wave #1');
    await waveTxn.wait();

    const waveTxn2 = await waveContract.wave('This is wave #2');
    await waveTxn2.wait();

    contractBlance = await hre.ethers.provider.getBalance(waveContract.address);
    console.log(
        'Contract balance: ',
        hre.ethers.utils.formatEther(contractBlance)
    );

    let allWaves = await waveContract.getAllWaves();
    console.log("All waves: :", allWaves);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();