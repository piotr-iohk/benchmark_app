DB_PATH = ENV.fetch("BENCH_DB_PATH") # ENV var for sqlite db file
BUILDKITE_API_TOKEN = ENV.fetch("BUILDKITE_API_TOKEN")

MAINNET_RESTORE_FILE = "restore-mainnet.txt"
TESTNET_RESTORE_FILE = "restore-testnet.txt"

MAINNET_RESTORE_JOB = "Restore benchmark - cardano mainnet"
TESTNET_RESTORE_JOB = "Restore benchmark - cardano testnet"

LATENCY_CATEGORIES = ["+++ Run benchmark - jormungandr",
                      "+++ Run benchmark - shelley"]

LATENCY_BENCHMARKS = ["Non-cached run",
                      "Latencies for 2 fixture wallets scenario",
                      "Latencies for 10 fixture wallets scenario",
                      "Latencies for 100 fixture wallets",
                      "Latencies for 2 fixture wallets with 10 txs scenario",
                      "Latencies for 2 fixture wallets with 20 txs scenario",
                      "Latencies for 2 fixture wallets with 100 txs scenario",
                      "Latencies for 10 fixture wallets with 10 txs scenario",
                      "Latencies for 10 fixture wallets with 20 txs scenario",
                      "Latencies for 10 fixture wallets with 100 txs scenario",
                      "Latencies for 2 fixture wallets with 100 utxos scenario",
                      "Latencies for 2 fixture wallets with 200 utxos scenario",
                      "Latencies for 2 fixture wallets with 500 utxos scenario",
                      "Latencies for 2 fixture wallets with 1000 utxos scenario"
                     ]

LATENCY_MEASUREMENTS = ["listWallets",
                        "getWallet",
                        "getUTxOsStatistics",
                        "listAddresses",
                        "listTransactions",
                        "postTransactionFee",
                        "listStakePools",
                        "getNetworkInfo"
                       ]
