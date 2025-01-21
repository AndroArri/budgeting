<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase/client'
import { useAuthStore } from '../stores/auth'

interface UserProfile {
  id: string
  first_name: string | null
  last_name: string | null
  created_at: string
  updated_at: string
}

const authStore = useAuthStore()
const profile = ref<UserProfile | null>(null)
const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref('')

const formData = ref({
  first_name: '',
  last_name: ''
})

async function fetchProfile() {
  try {
    loading.value = true
    error.value = ''

    const { data, error: err } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', authStore.user?.id)
      .single()

    if (err) throw err

    profile.value = data
    formData.value = {
      first_name: data?.first_name || '',
      last_name: data?.last_name || ''
    }
  } catch (e) {
    error.value = 'Error loading profile'
    console.error('Error:', e)
  } finally {
    loading.value = false
  }
}

async function updateProfile() {
  try {
    saving.value = true
    error.value = ''
    success.value = ''

    const { error: err } = await supabase
      .from('user_profiles')
      .upsert({
        id: authStore.user?.id,
        first_name: formData.value.first_name,
        last_name: formData.value.last_name
      })

    if (err) throw err

    success.value = 'Profile updated successfully'
    await fetchProfile()
  } catch (e) {
    error.value = 'Error updating profile'
    console.error('Error:', e)
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchProfile()
})
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Profile</h1>
        <p class="mt-2 text-sm text-gray-700">Manage your profile information</p>
      </div>
    </div>

    <!-- Error Alert -->
    <div v-if="error" class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{{ error }}</div>
    </div>

    <!-- Success Alert -->
    <div v-if="success" class="mt-4 rounded-md bg-green-50 p-4">
      <div class="text-sm text-green-700">{{ success }}</div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Loading profile...</div>
    </div>

    <!-- Profile Form -->
    <div v-else class="mt-6">
      <div class="bg-white shadow sm:rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <form @submit.prevent="updateProfile" class="space-y-6">
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700">
                Email address
              </label>
              <div class="mt-1">
                <input
                  type="email"
                  :value="authStore.user?.email"
                  disabled
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm disabled:bg-gray-100"
                />
              </div>
            </div>

            <div>
              <label for="first_name" class="block text-sm font-medium text-gray-700">
                First name
              </label>
              <div class="mt-1">
                <input
                  id="first_name"
                  v-model="formData.first_name"
                  type="text"
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>
            </div>

            <div>
              <label for="last_name" class="block text-sm font-medium text-gray-700">
                Last name
              </label>
              <div class="mt-1">
                <input
                  id="last_name"
                  v-model="formData.last_name"
                  type="text"
                  class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>
            </div>

            <div class="flex justify-end">
              <button
                type="submit"
                :disabled="saving"
                class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50"
              >
                {{ saving ? 'Saving...' : 'Save' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>