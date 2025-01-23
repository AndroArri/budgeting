<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase/client'
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  XMarkIcon
} from '@heroicons/vue/24/outline'

interface Category {
  id: string
  title: string
  icon: string
  color: string
}

const categories = ref<Category[]>([])
const loading = ref(true)
const error = ref('')

const showModal = ref(false)
const editingCategory = ref<Category | null>(null)
const formData = ref({
  title: '',
  icon: '🏠',
  color: '#3B82F6'
})

const icons = ['🏠', '🚗', '🍔', '🎮', '🏥', '🎓', '💼', '🛒', '✈️', '🎭', '💪', '📱']
const colors = [
  '#3B82F6', // Blue
  '#EF4444', // Red
  '#10B981', // Green
  '#F59E0B', // Yellow
  '#8B5CF6', // Purple
  '#EC4899', // Pink
  '#6366F1', // Indigo
  '#14B8A6', // Teal
  '#F97316', // Orange
  '#06B6D4', // Cyan
  '#84CC16', // Lime
  '#9333EA'  // Violet
]

async function fetchCategories() {
  try {
    loading.value = true
    const { data, error: err } = await supabase
      .from('categories')
      .select('*')
      .order('created_at', { ascending: false })

    if (err) throw err
    categories.value = data
  } catch (e) {
    error.value = 'Error loading categories'
    console.error('Error:', e)
  } finally {
    loading.value = false
  }
}

function openModal(category: Category | null = null) {
  if (category) {
    editingCategory.value = category
    formData.value = {
      title: category.title,
      icon: category.icon,
      color: category.color
    }
  } else {
    editingCategory.value = null
    formData.value = {
      title: '',
      icon: '🏠',
      color: '#3B82F6'
    }
  }
  showModal.value = true
}

async function handleSubmit() {
  try {
    if (editingCategory.value) {
      const { error: err } = await supabase
        .from('categories')
        .update({
          title: formData.value.title,
          icon: formData.value.icon,
          color: formData.value.color
        })
        .eq('id', editingCategory.value.id)

      if (err) throw err
    } else {
      const user = await supabase.auth.getUser();
      const user_id = user.data.user?.id
      if (!user_id) {
        throw new Error('User ID is undefined')
      }
      const { error: err } = await supabase
        .from('categories')
        .insert({
          title: formData.value.title,
          icon: formData.value.icon,
          color: formData.value.color,
          user_id: user_id
        })

      if (err) throw err
    }

    showModal.value = false
    await fetchCategories()
  } catch (e) {
    error.value = 'Error saving category'
    console.error('Error:', e)
  }
}

async function deleteCategory(id: string) {
  if (!confirm('Are you sure you want to delete this category?')) return

  try {
    const { error: err } = await supabase
      .from('categories')
      .delete()
      .eq('id', id)

    if (err) throw err
    await fetchCategories()
  } catch (e) {
    error.value = 'Error deleting category'
    console.error('Error:', e)
  }
}

onMounted(() => {
  fetchCategories()
})
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Categories</h1>
        <p class="mt-2 text-sm text-gray-700">Manage your expense categories</p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <button
          type="button"
          @click="openModal()"
          class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-indigo-500"
        >
          <PlusIcon class="h-5 w-5 inline-block mr-1" />
          Add Category
        </button>
      </div>
    </div>

    <!-- Error Alert -->
    <div v-if="error" class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{{ error }}</div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Loading categories...</div>
    </div>

    <!-- Categories Grid -->
    <div v-else class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <div
        v-for="category in categories"
        :key="category.id"
        class="relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm"
      >
        <div
          class="flex-shrink-0 rounded-full p-2"
          :style="{ backgroundColor: category.color + '20' }"
        >
          <span class="text-2xl">{{ category.icon }}</span>
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-gray-900">{{ category.title }}</p>
        </div>
        <div class="flex-shrink-0 space-x-2">
          <button
            @click.prevent="openModal(category)"
            class="text-gray-400 hover:text-indigo-600"
          >
            <PencilSquareIcon class="h-5 w-5" />
          </button>
          <button
            @click.prevent="deleteCategory(category.id)"
            class="text-gray-400 hover:text-red-600"
          >
            <TrashIcon class="h-5 w-5" />
          </button>
        </div>
      </div>
    </div>

    <!-- Modal -->
    <div
      v-if="showModal"
      class="relative z-50"
      aria-labelledby="modal-title"
      role="dialog"
      aria-modal="true"
    >
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

      <div class="fixed inset-0 z-50 overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div class="absolute right-0 top-0 pr-4 pt-4">
              <button
                type="button"
                @click="showModal = false"
                class="rounded-md bg-white text-gray-400 hover:text-gray-500"
              >
                <XMarkIcon class="h-6 w-6" />
              </button>
            </div>

            <form @submit.prevent="handleSubmit">
              <div class="space-y-4">
                <div>
                  <label for="title" class="block text-sm font-medium text-gray-700">
                    Category Name
                  </label>
                  <input
                    type="text"
                    id="title"
                    v-model="formData.title"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Icon</label>
                  <div class="mt-2 grid grid-cols-6 gap-2">
                    <button
                      v-for="icon in icons"
                      :key="icon"
                      type="button"
                      @click="formData.icon = icon"
                      :class="[
                        'p-2 rounded-md text-xl',
                        formData.icon === icon
                          ? 'bg-indigo-100 ring-2 ring-indigo-500'
                          : 'hover:bg-gray-100'
                      ]"
                    >
                      {{ icon }}
                    </button>
                  </div>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Color</label>
                  <div class="mt-2 grid grid-cols-6 gap-2">
                    <button
                      v-for="color in colors"
                      :key="color"
                      type="button"
                      @click="formData.color = color"
                      :class="[
                        'w-8 h-8 rounded-full',
                        formData.color === color
                          ? 'ring-2 ring-offset-2 ring-indigo-500'
                          : ''
                      ]"
                      :style="{ backgroundColor: color }"
                    />
                  </div>
                </div>
              </div>

              <div class="mt-5 sm:mt-6">
                <button
                  type="submit"
                  class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                >
                  {{ editingCategory ? 'Update' : 'Create' }} Category
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>