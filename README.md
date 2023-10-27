# Locketh

Locket is an autonomous, immutable protocol that enables to lock ETH until a given timestamp has passed.
In exchange for the ETH locked until timestamp X, the depositor receives `lockETH-X` tokens that can be exchanged freely on secondary markets like [Uniswap](https://app.uniswap.org/).

It notably defines a risk-free rate: the holder of `lockETH-X` is guaranteed to be able to redeem their tokens for the same amount of ETH starting from timestamp X,
but they can sell it at a discount on secondary markets for short-term liquidity.
The price will implicitely define an interest rate on ETH between the time it was purchased and X.
For example, a price of 0.95 (0.95 ETH can be exchanged for 1 lockETH-X) will imply a risk-free rate of 5% until X.
