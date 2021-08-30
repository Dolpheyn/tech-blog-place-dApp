<template>
  <q-page>
    <div class="column items-center justify-evenly">
      <h2>Hello 🐬</h2>

      <div class="q-pa-md" style="max-width: 700px">
        I'm Dolpheyn and I like reading beautiful technical blogs and blogposts.
        Connect your Ethereum wallet and recommend one of your favourites to me.
        Feel free to also recommend your personal blog!
      </div>

      <q-btn v-if="!userAddr" @click="connectWallet">
        Connect Wallet
      </q-btn>

      <div class="q-ma-md" style="width: 400px">
        <q-input type="textarea" v-model="blogLink" />
      </div>

      <q-btn @click="sendRecommendation">Recommend</q-btn>

      <div class="q-mt-md" v-if="allRecommendations.length">
        <div v-for="rec in allRecommendations" :key="rec.timestamp._hex" >
          <div>
            {{rec.recommender}} recommended 
            <a :href="rec.blog" target="blank">{{rec.blog}}</a>
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { ethers } from 'ethers'
import abi from '../utils/TechBlogPlace.json'

declare let window: any

const contractAddress = '0x27B1c57093B297823e47102e9EcAe61Ac5764eC9'
const contractABI = abi.abi

export default defineComponent({
  name: 'PageIndex',

  data() {
    let contract: any = null;
    let userAddr = '';
    let blogLink = ''
    let allRecommendations: string[] = []

    return {
      userAddr, blogLink, contract, allRecommendations, 
    };
  },

  created() {
    this.checkIfWalletIsThere()
  },

  methods: {
    checkIfWalletIsThere() {
      window.addEventListener('load', () => {
        const { ethereum } = window
        if (!ethereum) {
          console.log('No metamask')
        } else {
          console.log('We have an ethereum object!!', ethereum)
        }

        ethereum.request({ method: 'eth_accounts' })
          .then(async accounts => {
            console.log('Available accounts: ', accounts)
            if (accounts.length !== 0) {
              console.log('We have an authorized account')
              this.userAddr = accounts[0]
              await this.getAllRecommendations()
            } else {
              console.log('User has not given us perms')
            }
          })
      })
    },

    connectWallet() {
      const { ethereum } = window
      ethereum.request({ method: 'eth_requestAccounts' })
        .then(async accounts => {
          console.log(`Accounts: ${accounts}`)
          this.userAddr = accounts[0]

          await this.getAllRecommendations()
        })
    },

    setContract() {
      const { ethereum } = window
      console.log(ethereum)
      const provider = new ethers.providers.Web3Provider(ethereum)
      const signer = provider.getSigner()

      this.contract = new ethers.Contract(contractAddress, contractABI, signer)
    },

    async getAllRecommendations() {
      if(!this.contract) this.setContract()

      let recommendations = await this.contract.getAllRecommendations()
      console.log(recommendations)

      this.allRecommendations = recommendations
    },

    async sendRecommendation() {
      if(!this.contract) this.setContract()

      let count = await this.contract.getTotalRecommendations()
      console.log(`Recommendation count: ${count}`)

      const recTxn = await this.contract.recommend(this.blogLink)
      console.log(`Mining txn: ${recTxn.hash}`)

      await recTxn.wait()
      console.log(`Mined! ${recTxn.hash}`)

      count = await this.contract.getTotalRecommendations()
      console.log(`New recommendation count: ${count}`)

      await this.getAllRecommendations()
    }
  }
});
</script>
