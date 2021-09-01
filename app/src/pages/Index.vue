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
        style="height: 400px !important; min-width: 500px; overflow: hidden scroll"
      >
        <q-chat-message label="Tech Blog Place" />

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

      <q-btn
        @click="sendRecommendation"
        color="primary"
        :disabled="!blogLink.length"
      >Recommend</q-btn>
    </div>
  </q-page>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { ethers } from 'ethers'
import { date, Notify } from 'quasar'
import abi from '../utils/TechBlogPlace.json'

declare let window: any

const goerliChainId = '0x5'
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

          Notify.create({
            actions: [
              { label: 'Reload', color: 'primary', handler: () => {
                this.$router.go(0)
              }},
              { label: 'Dismiss', color: 'secondary', handler: () => {} },
            ],
            color: 'negative',
            icon: 'error',
            message: 'Metamask wallet is required to use this app.',
            multiLine: true,
            position: 'top',
            timeout: 0,
          })

          return
        }

        console.log('We have an ethereum object!!', ethereum)

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
      const result = { isOkay: false }

      // Check if user is on the right chain
      if(ethereum.chainId !== goerliChainId) {
        Notify.create({
          actions: [
            { label: 'Reload', color: 'primary', handler: () => {
              this.$router.go(0)
            }},
            { label: 'Dismiss', color: 'secondary', handler: () => {} },
          ],
          color: 'negative',
          icon: 'error',
          message: 'You are not on the Goerli chain. Change your network in Metamask to continue',
          multiLine: true,
          position: 'top',
          timeout: 0,
        })

        return result
      }

      const provider = new ethers.providers.Web3Provider(ethereum)
      const signer = provider.getSigner()

      this.contract = new ethers.Contract(contractAddress, contractABI, signer)

      result.isOkay = true
      return result
    },

    async getAllRecommendations() {
      if(!this.contract) {
        const result = this.setContract()
        if(!result.isOkay) return
      }

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
      if(!this.contract) {
        const result = this.setContract()
        if(!result.isOkay) return
      }

      let count = await this.contract.getTotalRecommendations()
      console.log(`Recommendation count: ${count}`)

      const recTxn = await this.contract.recommend(this.blogLink)
      console.log(`Mining txn: ${recTxn.hash}`)
      const notif = Notify.create({
        color: 'info',
        group: false,
        message: 'Mining your recommendation transaction.',
        position: 'top',
        spinner: true,
        timeout: 0,
      })

      await recTxn.wait()
      console.log(`Mined! ${recTxn.hash}`)
      notif({
        color: 'positive',
        icon: 'done',
        message: 'Done! Thank you for recommending, I sent 0.001 eth to your wallet. Enjoy!',
        spinner: false,
        timeout: 1000,
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
