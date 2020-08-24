DB_PATH = ENV.fetch("BENCH_DB_PATH") # ENV var for sqlite db file
BUILDKITE_API_TOKEN = ENV.fetch("BUILDKITE_API_TOKEN")

MAINNET_RESTORE_FILE = "restore-mainnet.txt"
TESTNET_RESTORE_FILE = "restore-testnet.txt"

MAINNET_RESTORE_JOB = "Restore benchmark - cardano mainnet"
TESTNET_RESTORE_JOB = "Restore benchmark - cardano testnet"
