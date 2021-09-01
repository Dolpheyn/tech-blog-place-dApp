<template>
  <q-page>
    <q-btn
      class="btn-wallet"
      v-if="!userAddr"
      @click="connectWallet"
    >
      Connect Wallet
    </q-btn>
    <div class="column items-center justify-evenly q-py-md">
      <h2>Hello 🐬</h2>

      <div style="max-width: 700px">
        I'm Dolpheyn and I like reading beautiful technical blogs and blogposts.
        Connect your Ethereum wallet and recommend one of your favourites to me.
        Feel free to also recommend your personal blog!
      </div>

      <div
        class="q-mt-md q-mb-xl"
        v-if="allRecommendations.length"
        style="max-height: 400px !important; min-width: 500px; overflow: hidden scroll">
        <div v-for="rec in allRecommendations" :key="rec.timestamp._hex" >
          <q-chat-message
            :name="rec.recommender"
            :stamp="rec.timestamp"
            :bg-color="rec.isUserSent ? 'lightblue' : 'lightgrey'"
            :sent="rec.isUserSent"
          >
            <a :href="rec.blog" target="blank">{{rec.blog}}</a>
          </q-chat-message>
        </div>
      </div>

      <div style="min-width: 500px" class="q-mb-md">
        <q-input rounded outlined v-model="blogLink"/>
      </div>

      <q-btn @click="sendRecommendation" color="primary">Recommend</q-btn>
    </div>
  </q-page>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { ethers } from 'ethers'
import { date, Notify } from 'quasar'
import abi from '../utils/TechBlogPlace.json'

declare let window: any

const contractAddress = '0xdE79558Fd209CA933Bc84006f6670561F266FE9f'
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

      recommendations = recommendations.map(r => {
        const timestamp = date.formatDate(new Date(r.timestamp * 1000),
                                          'YYYY-MM-DD HH:mm')
        const recommender = r.recommender.substr(0, 6)
        const isUserSent = this.userAddr.substr(0, 6) == recommender

        return {
          ...r,
          timestamp,
          recommender,
          isUserSent,
        }
      })
      console.log(recommendations)

      this.allRecommendations = recommendations
    },

    async sendRecommendation() {
      if(!this.contract) this.setContract()

      let count = await this.contract.getTotalRecommendations()
      console.log(`Recommendation count: ${count}`)

      const recTxn = await this.contract.recommend(this.blogLink)
      console.log(`Mining txn: ${recTxn.hash}`)
      const notif = Notify.create({
        group: false,
        message: 'Mining your recommendation transaction.',
        position: 'top',
        spinner: true,
        timeout: 0,
        color: 'info',
      })

      await recTxn.wait()
      console.log(`Mined! ${recTxn.hash}`)
      notif({
        icon: 'done',
        spinner: false,
        message: 'Done! Thank you for recommending, I sent 0.001 eth to your wallet. Enjoy!',
        timeout: 1000,
        color: 'positive',
      })

      count = await this.contract.getTotalRecommendations()
      console.log(`New recommendation count: ${count}`)

      await this.getAllRecommendations()
    }
  }
});
</script>

<style scoped>
.btn-wallet {
  position: absolute;
  right: 50px;
}
</style>
