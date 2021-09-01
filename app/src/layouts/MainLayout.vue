<template>
  <q-layout view="lHh Lpr lFf">
    <q-header class="my-header">
      <q-toolbar>
        <q-toolbar-title class="row">
          <q-img
            src="../assets/tech-blog-place.png"
            style="height: 50px; width: 250px"
            class="q-ma-sm"
          />
        </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'MainLayout',

  data() {
    return {
    }
  },

  methods: {
  }
  })
</script>

<style scoped>
.my-header {
  background-color: white;
}
</style>
