require('dotenv').config()

const settings = {
    kovan_url: process.env.KOVAN_URL,
    etherscan_key: process.env.ETHERSCAN_API_KEY,
    ac_pk: process.env.AC_PK
}

exports.default = settings
