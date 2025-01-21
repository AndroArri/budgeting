<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from './stores/auth'
import AppLayout from './components/AppLayout.vue'

const authStore = useAuthStore()

onMounted(() => {
  authStore.initialize()
})
</script>

<template>
  <AppLayout v-if="!$route.meta.requiresAuth === false">
    <router-view v-slot="{ Component }">
      <component :is="Component" />
    </router-view>
  </AppLayout>
  <router-view v-else v-slot="{ Component }">
    <component :is="Component" />
  </router-view>
</template>